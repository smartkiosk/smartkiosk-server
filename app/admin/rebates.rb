ActiveAdmin.register Rebate do
  menu :parent => I18n.t('activerecord.models.gateway.other'), 
       :if     => proc { can? :index, Rebate }

  #
  # INDEX
  #
  scope I18n.t('active_admin.all'), :all
  scope I18n.t('activerecord.scopes.rebate.active'), :active, :default => true
  scope I18n.t('activerecord.scopes.rebate.outdated'), :outdated

  filter :id
  filter :gateway, :as => 'multiple_select', :input_html => { :class => 'chosen' }
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    column :id, :sortable => :id do |x|
      link_to x.id, [:admin, x]
    end
    column :gateway
    column :start
    column :finish
  end

  #
  # SHOW
  #
  show do |rebate|
    attributes_table do
      row :id
      row :gateway
      row :created_at
      row :updated_at
    end
  end

  #
  # FORM
  #
  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :gateway, :input_html => {
        :class    => 'chosen',
        :onchange => "location.href = '/admin/rebates/new?rebate[gateway_id]='+$(this).val()",
        :disabled => !f.object.new_record?
      }
      if rebate.gateway.blank?
        f.form_buffers.last << content_tag(:li, I18n.t('smartkiosk.admin.messages.rebates.choose_gateway'))
      elsif rebate.gateway.providers.count < 1
        f.form_buffers.last << content_tag(:li, I18n.t('smartkiosk.admin.messages.rebates.no_providers'))
      else
        f.input :period_kind, :as => :select, :collection => I18n.t('smartkiosk.rebate_periods').invert,
          :input_html => { :class => 'chosen' }
        f.input :period_fee
        f.input :start, :as => :datepicker
        f.input :finish, :as => :datepicker
      end

      f.form_buffers.last
    end

    unless rebate.gateway.blank?
      f.inputs do
        f.has_many :provider_rebates do |prf|
          prf.semantic_errors
          prf.input :provider, :collection => rebate.gateway.providers, :input_html => { :class => 'chosen' }
          prf.input :payment_type, :as => :select, :input_html => { :class => 'chosen' }, :collection => I18n.t('smartkiosk.payment_types').invert
          prf.input :requires_commission, :as => :select, :input_html => { :class => 'chosen' }
          prf.input :min
          prf.input :max
          prf.input :min_percent_amount
          prf.input :percent_fee
          prf.input :static_fee
        end
      end
    end

    f.actions
  end
end
