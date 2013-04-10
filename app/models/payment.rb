class Payment < ActiveRecord::Base
  include DateExpander
  include Stateflow
  include Redis::Objects

  SOURCE_INNER  = 0
  SOURCE_MANUAL = 1
  SOURCE_IMPORT = 2

  TYPE_CASH         = 0
  TYPE_INNER_CARD   = 1
  TYPE_FOREIGN_CARD = 2
  TYPE_IBANK        = 3
  TYPE_MBANK        = 4
  TYPE_PURSE        = 5
  TYPE_ACCOUNT      = 6

  value :pin_block

  #
  # STATEFLOW
  #
  stateflow do
    state :new, :checked, :declined, :queue, :paid, :error, :manual

    event :check do
      transitions :from => :new, :to => [:checked, :declined], :decide => :check?
    end

    event :enqueue do
      transitions :from => [:error, :checked], :to => :queue
    end

    event :pay do
      transitions :from => [:checked, :queue], :to => [:paid, :error], :decide => :pay?
    end

    event :pay_offline do
      transitions :from => :new, :to => [:paid, :error], :decide => :pay_offline?
    end

    event :pay_manually do
      transitions :from => :error, :to => :manual
    end

    event :requeue do
      transitions :from => :error, :to => :queue
    end
  end

  def pay_manually!(user)
    pay_manually
    save!

    Version.create!(
      :item_type => self.class.to_s,
      :item_id   => self.id,
      :event     => "payment.paid_manually",
      :whodunnit => user.id
    )
  end

  def requeue!(user)
    requeue
    save!

    PayWorker.perform_async(self.id)
    Version.create!(
      :item_type => self.class.to_s,
      :item_id   => self.id,
      :event     => "payment.requeued",
      :whodunnit => user.id
    )
  end

  def assign_payment_attributes(attributes)
    [ :paid_amount, :receipt_number, :card_track1, :card_track2, :meta ].each do |key|
      if attributes.include? key
        write_attribute key, attributes[key]
      end
    end
  end

  def enqueue!(attributes={})
    plog :info, :model, "Sent to queue" do
      assign_payment_attributes attributes
      enqueue
      save!
      PayWorker.perform_async(id)
    end
  end

  def pay!(attributes={})
    plog :info, :model, "Paid" do
      assign_payment_attributes attributes
      pay
      save!
    end
  end

  #
  # RELATIONS
  #
  belongs_to :agent
  belongs_to :terminal
  belongs_to :provider
  belongs_to :gateway
  belongs_to :user
  belongs_to :corrected_payment, :class_name => 'Payment'
  has_one    :corrected_by, :foreign_key => 'corrected_payment_id', :class_name => 'Payment'

  scope :queued, where(:state => 'queue')
  scope :error,  where(:state => 'error')
  scope :recent, order('created_at DESC')

  #
  # VALIDATIONS
  #
  validates :gateway, :presence => true
  validates :provider, :presence => true, :if => lambda{|x| x.source == SOURCE_INNER}
  validates :terminal, :presence => true, :if => lambda{|x| x.source == SOURCE_INNER}
  validates :agent, :presence => true, :if => lambda{|x| x.source == SOURCE_INNER}
  validates :commission_amount, :presence => true, :if => lambda{|x| x.source == SOURCE_MANUAL}
  validates :enrolled_amount, :presence => true, :if => lambda{|x| x.source == SOURCE_MANUAL}
  validates :session_id, :uniqueness => {:scope => :terminal_id}, :unless => lambda{|x| x.terminal.blank?}
  validates :user, :presence => true, :if => lambda{|x| x.source == SOURCE_MANUAL}
  validates :payment_type, :presence => true

  #
  # MODIFICATIONS
  #
  before_validation do
    self.meta  = {} unless self.meta.is_a?(Hash)
    self.agent = self.terminal.agent unless self.terminal.blank?

    if [ TYPE_CASH, TYPE_IBANK, TYPE_MBANK, TYPE_PURSE, TYPE_ACCOUNT ].include?(self.payment_type)
      self.externally_paid = true
    end
  end

  before_save do
    if !self.paid_amount.nil? && (self.enrolled_amount.nil? || self.commission_amount.nil?)
      self.commission_amount = Commission.for(self).first.try(:fee, paid_amount) || 0
      self.enrolled_amount = self.paid_amount - self.commission_amount
    end

    if self.paid_amount.nil? && !self.enrolled_amount.nil? && !self.commission_amount.nil?
      self.paid_amount = self.enrolled_amount + self.commission_amount
    end

    if !self.paid_amount.nil? && !self.commission_amount.nil? && self.rebate_amount.nil?
      rebate = Rebate.for(self)
      self.rebate_amount = rebate.try(:fee, paid_amount) || 0
    end
  end

  after_create do
    if source == SOURCE_MANUAL
      Version.create!(
        :item_type => self.class.to_s,
        :item_id   => self.id,
        :event     => "create",
        :whodunnit => user.id
      )
    end
  end

  serialize :fields
  serialize :raw_fields
  serialize :meta

  #
  # METHODS
  #
  def self.acquirer(payment)
    unless payment.externally_paid
      unless @acquiring_settings
        @acquiring_settings = YAML::load File.read(Rails.root.join 'config/acquiring.yml')
        @acquiring_settings.each do |x|
          x['type'] = x['type'].split(',').map do |t|
            Payment.const_get "TYPE_#{t.strip.upcase}"
          end
          x['class'] = x['class'].constantize
        end
      end

      acquirer = @acquiring_settings.find{|x| x['type'].include?(payment.payment_type)}
      raise "unsupported payment type: #{payment.payment_type}" unless acquirer

      acquirer['class'].new(acquirer)
    else
      EmptyAcquirer.new
    end
  end

  def self.plogger
    return @plogger if @plogger

    @plogger ||= Logger.new(Rails.root.join('log/payments.log'), 10, 1024000)

    separator = ' | '

    @plogger.formatter = proc { |severity, datetime, data, message|
      data ||= {}

      header = "~~ " + [
        severity,
        datetime.iso8601(12),
        data[:progname],
        "##{data[:payment_id]}",
        data[:payment_state],
        data[:session_id],
        data[:terminal_id],
        data[:gateway_id],
        message
      ].join(separator) + "\n"
    }

    @plogger
  end

  def self.plog(severity, progname, message, data={})
    data[:progname] = progname

    unless block_given?
      plogger.send(severity, data){ message }
    else
      begin
        yield
      rescue Exception => e
        plogger.error(data){ e }
        raise e
      else
        plogger.send(severity, data){ message }
      end
    end
  end

  def plog(severity, progname, message, &block)
    data = {
      :payment_id    => self.id,
      :payment_state => self.state,
      :session_id    => self.session_id,
      :terminal_id   => self.terminal_id,
      :gateway_id    => self.gateway_id
    }

    self.class.plog(severity, progname, message, data, &block)
  end

  def manual?
    source == SOURCE_MANUAL
  end

  def complete?
    %w(paid manual).include? state
  end

  def cash?
    payment_type == TYPE_CASH
  end

  def cashless?
    !cash?
  end

  def self.build!(terminal, provider, attributes)
    payment = new(attributes)

    if provider.blank?
      payment.plog :warn, :model, "Provider not found"
      return false
    end
    
    provider_gateway = provider.provider_gateways.enabled.order(:priority).first

    if provider_gateway.blank?
      payment.plog :info, :model, "Provider has no gateways attached"
      return false
    end

    payment.terminal = terminal
    payment.provider_gateway = provider_gateway
    payment.raw_fields = payment.fields
    payment.fields = provider_gateway.map(payment.account, payment.fields)

    if payment.save
      payment.plog :info, :model, "Payment created"
      payment
    else
      payment.plog :warn, :model, "Payment was invalidated: #{payment.errors.full_messages.join(', ')}"
      false
    end
  end

  def provider_gateway=(pg)
    self.gateway = pg.gateway
    self.provider = pg.provider
    self.gateway_provider_id = pg.gateway_provider_id
  end

  def title
    "##{id}: #{provider.try(:title)} (#{account || '--'})"
  end

  def human_fields=(value)
    self.fields = value.gsub("\r", '').split("\n").map{|x| x.split('=')}
    self.fields = Hash[*self.fields.select{|x| x.length > 1}.flatten]
  end

  def human_fields
    return '' if self.fields.blank?
    self.fields.collect{|k,v| "#{k}=#{v}"}.join("\n")
  end

  def check?
    result = self.gateway.librarize.check(self)

    if result[:success]
      plog :info, :model, "Checked"
      self.gateway_error      = nil
      self.gateway_payment_id = result[:gateway_payment_id] unless result[:gateway_payment_id].blank?
      self.save!
      return :checked
    else
      plog :info, :model, "Declined: #{result[:error]}"
      self.update_attribute(:gateway_error, result[:error])
      return :declined
    end
  end

  def pay?
    acquirer = Payment.acquirer(self)
    acquirer.transaction(self) do |transaction|
      self.update_attribute(:acquirer_transaction, transaction.id)

      if transaction.authorize
        result = self.gateway.librarize.pay(self)

        if result[:success]
          self.gateway_error      = nil
          self.gateway_payment_id = result[:gateway_payment_id] unless result[:gateway_payment_id].blank?
          self.paid_at            = DateTime.now
          self.meta[:gateway]     = self.gateway.serialize_options

          self.save!
          if !transaction.confirm
            self.plog :error, :model, "unable to confirm transaction: #{transaction.error}"

            # TODO: reverse on gateway if possible
          end

          return :paid
        else
          self.update_attribute(:gateway_error, result[:error])
          if !transaction.reverse
            self.plog :error, :model, "unable to reverse transaction: #{transaction.error}"
          end

          return :error
        end
      else
        self.update_attribute(:acquirer_error, transaction.error)
        return :error
      end
    end
  end

  def approved?
    !['new', 'declined'].include?(state)
  end
end