class TerminalPing
  include ActiveAttr::Model
  include ActiveModel::Translation
  include ActiveModel::Callbacks
  extend Machinist::Machinable

  def self.i18n_scope
    :activerecord
  end

  attribute :state, :type => String, :default => 'unknown'
  attribute :condition, :type => String
  attribute :version
  attribute :ip, :type => String

  # '100' => 1, '1000' => 5
  attribute :banknotes, :default => {}    

  # :error => '...', :version => '...'
  attribute :cash_acceptor, :default => {}

  # :error => '', :version => ''
  attribute :printer, :default => {}

  # :error => '', :version => '', :signal_level => 4, :balance => 54.5
  attribute :modem, :default => {}

  attribute :card_reader, :default => {}
  attribute :watchdog, :default => {}

  # :payments => 5, :orders => 4
  attribute :queues, :default => {}

  attribute :created_at, :type => DateTime, :default => proc { DateTime.now }

  def value(field, hardware)
    source = (send(hardware) || {}) rescue {}
    source[field].blank? ? nil : source[field]
  end

  def error(*hardware)
    if hardware.count == 1
      v = value('error', hardware.first)
      return v.nil? ? nil : v.to_i
    else
      return hardware.map do |x|
        v = value('error', x)
        v.nil? ? nil : v.to_i
      end
    end
  end

  def valid?(*args)
    codes = error(*Terminal::HARDWARE).compact

    self.condition = 
      if codes.blank?
        'ok'
      elsif codes.min >= 1000
        'warning'
      else
        'error'
      end

    super
  end

  def ok?
    condition == 'ok'
  end

  def cash_sum
    banknotes.collect{|k,v| k.to_i*v.to_i}.sum
  end

  def cash_count
    banknotes.values.map{|x| x.to_i}.sum
  end

  def card_reader_error
    error(:card_reader)
  end

  def card_reader_version
    value 'version', :card_reader
  end

  def card_reader_model
    value 'model', :card_reader
  end

  def watchdog_error
    error(:watchdog)
  end

  def watchdog_version
    value 'version', :watchdog
  end

  def watchdog_model
    value 'model', :watchdog
  end

  def cash_acceptor_error
    error(:cash_acceptor)
  end

  def cash_acceptor_version
    value 'version', :cash_acceptor
  end

  def cash_acceptor_model
    value 'model', :cash_acceptor
  end

  def printer_error
    error(:printer)
  end

  def printer_version
    value 'version', :printer
  end

  def printer_model
    value 'model', :printer
  end

  def modem_error
    error(:modem)
  end

  def modem_version
    value 'version', :modem
  end

  def modem_balance
    modem['balance']
  end

  def modem_signal_level
    modem['signal_level']
  end

  def modem_model
    value 'model', :modem
  end
end