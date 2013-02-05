ActiveAdmin.register Payment do
  actions :index, :show, :new, :create

  controller do
    def scoped_collection
      Payment.includes(:terminal, :provider)
    end

    def create
      @payment.source = Payment::SOURCE_MANUAL
      @payment.user   = current_user

      Payment.transaction do
        unless @payment.save
          render :action => 'new' 
          return
        end

        @payment.check!

        unless @payment.state == 'checked'
          @payment = Payment.new(@payment.attributes)
          @payment.errors[:base] << I18n.t('activerecord.errors.models.payment.declined')
          render :action => 'new'
          raise ActiveRecord::Rollback
        end

        @payment.enqueue!
        @payment.corrected_payment.pay_manually!(@payment.user) rescue false

        redirect_to [:admin, @payment]
      end
    end
  end

  member_action :confirm, :method => :post do
    payment = Payment.find(params[:id])
    payment.pay_manually!(current_user)
    redirect_to :action => :show
  end

  member_action :requeue, :method => :post do
    payment = Payment.find(params[:id])
    payment.requeue!(current_user)
    redirect_to :action => :show
  end

  #
  # INDEX
  #
  batch_action I18n.t('smartkiosk.admin.actions.payments.paid_manually') do |selection|
    Payment.find(selection).each do |p|
      p.pay_manually!(current_user) if p.state == 'error'
    end

    redirect_to :back
  end

  batch_action I18n.t('smartkiosk.admin.actions.payments.repay') do |selection|
    Payment.find(selection).each do |p|
      p.requeue!(current_user) if p.state == 'error'
    end

    redirect_to :back
  end

  scope I18n.t('active_admin.all'), :all
  scope I18n.t('activerecord.scopes.payment.queued'), :queued
  scope I18n.t('activerecord.scopes.payment.error'), :error

  filter :id
  filter :state, :as => 'multiple_select',
    :input_html => { :class => 'chosen' },
    :collection => proc { I18n.t('smartkiosk.payment_states').invert }
  filter :source, :as => 'multiple_select',
    :input_html => { :class => 'chosen' },
    :collection => proc { I18n.t('smartkiosk.payment_sources').invert }
  filter :agent, :as => 'multiple_select', :input_html => { :class => 'chosen' },
    :collection => proc { Agent.rmap }
  filter :terminal, :as => 'multiple_select', :input_html => { :class => 'chosen' }
  filter :session_id
  filter :gateway, :as => 'multiple_select', :input_html => { :class => 'chosen' }
  filter :provider, :as => 'multiple_select', :input_html => { :class => 'chosen' }
  filter :account
  filter :paid_amount, :as => 'numeric_range'
  filter :commission_amount, :as => 'numeric_range'
  filter :rebate_amount, :as => 'numeric_range'
  filter :created_at

  index do
    selectable_column
    column :id, :sortable => :id do |x|
      link_to x.id, [:admin, x]
    end
    column :terminal
    column :session_id
    column :account
    column :provider
    column :state, :sortable => :state do |x|
      condition = :ok
      condition = :warning if ['queue', 'checked'].include?(x.state)
      condition = :error if x.state == 'error'
      status_tag I18n.t("smartkiosk.payment_states.#{x.state}"), condition
    end
    column :paid_amount, :sort => :paid_amount do |x|
      div :title => "#{x.enrolled_amount} + #{x.commission_amount}" do
        x.paid_amount
      end
    end
    column :rebate_amount
    column :date, :sortable => :created_at do |x|
      div :class => 'nowrap', :title => Payment.human_attribute_name(:created_at) do
        status_tag I18n.l(x.created_at, :format => :long), :raw
      end
      if x.paid?
        div :class => 'nowrap', :title => Payment.human_attribute_name(:paid_at) do
          status_tag I18n.l(x.paid_at, :format => :long), :ok
        end
      elsif x.error?
        div :class => 'nowrap', :title => Payment.human_attribute_name(:updated_at) do
          status_tag I18n.l(x.updated_at, :format => :long), :error
        end
      else
        div :class => 'nowrap', :title => Payment.human_attribute_name(:updated_at) do
          status_tag I18n.l(x.updated_at, :format => :long), :warning
        end
      end
    end
  end

  #
  # SHOW
  #
  action_item :only => [:show], :if => proc { ['error'].include? payment.state } do
    link_to I18n.t('smartkiosk.admin.actions.payments.paid_manually'),
      confirm_admin_payment_path(payment), :method => :post
  end

  action_item :only => [:show], :if => proc { ['error'].include? payment.state } do
    link_to I18n.t('smartkiosk.admin.actions.payments.repay'),
      requeue_admin_payment_path(payment), :method => :post
  end

  show do
    attributes_table do
      row :id
      row :session_id
      row :terminal do |x|
        unless x.terminal.blank?
          link_to x.terminal.keyword, admin_terminal_path(x.terminal)
        end
      end
      row :state do |x|
        condition = :ok
        condition = :warning if x.state == 'queue'
        condition = :error if x.state == 'error'
        status_tag I18n.t("smartkiosk.payment_states.#{x.state}"), condition
      end
      row :gateway
      row :provider
      row :paid_amount
      row :enrolled_amount
      row :commission_amount
      row :rebate_amount
      row :created_at
      row :updated_at
      row :account
      row :user
      row :fields do |x|
        unless x.fields.blank?
          x.fields.each do |k,v|
            li do
              b("#{k}:")
              span(v)
            end
          end
        end
      end
      row :raw_fields do |x|
        unless x.fields.blank?
          x.fields.each do |k,v|
            li do
              b("#{k}:")
              span(v)
            end
          end
        end
      end
      row :gateway_provider_id
      row :gateway_payment_id
      row :gateway_error do |x|
        unless x.gateway_error.blank?
          (
            I18n.t("smartkiosk.gateways.#{x.gateway.keyword}.errors")[x.gateway_error] || 
            I18n.t('smartkiosk.unlocalized')
          ) + " (#{x.gateway_error})"
        end
      end
      row :payment_type do |x|
        I18n.t('smartkiosk.payment_types')[x.payment_type]
      end
      row :source do |x|
        I18n.t('smartkiosk.payment_sources')[x.source]
      end
      row :corrected_payment
      row :corrected_by
    end

    active_admin_comments
  end

  #
  # FORM
  #
  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :user_id, :as => :hidden, :input_html => {:value => current_user.id}
      f.input :corrected_payment_id, :as => :string, :input_html => { :id => 'cpi' }
      f.input :gateway, :collection => Gateway.enabled, :input_html => {
        :class    => 'chosen',
        :onchange => "location.href = '/admin/payments/new?payment[gateway_id]='+$(this).val()+'&payment[corrected_payment_id]='+$('#cpi').val()"
      }
      if payment.gateway.blank?
        f.form_buffers.last << content_tag(:li, I18n.t('smartkiosk.admin.messages.payments.choose_gateway'))
      elsif payment.gateway.providers.count < 1
        f.form_buffers.last << content_tag(:li, I18n.t('smartkiosk.admin.messages.payments.no_providers'))
      else
        f.input :provider, :input_html => {:class => 'chosen'}, :collection => payment.gateway.providers
        f.input :gateway_provider_id
        f.input :account
        f.input :human_fields, :as => :text, :hint => "foo=bar<br/>bar=baz".html_safe
        f.input :enrolled_amount, :required => true
        f.input :commission_amount, :required => true
        f.input :payment_type, :as => :select, :collection => I18n.t('smartkiosk.payment_types').invert,
          :input_html => { :class => 'chosen' }
      end

      f.form_buffers.last
    end

    if !payment.gateway.blank? && payment.gateway.providers.count > 0
      f.actions
    end

    f.form_buffers.last
  end
end
