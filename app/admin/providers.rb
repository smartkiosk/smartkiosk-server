ActiveAdmin.register Provider do

  menu :parent   => I18n.t('activerecord.models.provider.other'), 
       :label    => I18n.t('smartkiosk.admin.menu.manage'), 
       :priority => 1, 
       :if       => proc { can? :index, Provider }

  controller do
    def scoped_collection
      Provider.includes(:provider_profile)
    end
  end

  #
  # INDEX
  #
  filter :id
  filter :provider_profile, :as => 'multiple_select', :input_html => { :class => 'chosen' },
    :collection => proc { ProviderProfile.rmap }
  filter :provider_group, :as => 'multiple_select', :input_html => { :class => 'chosen' }
  filter :title
  filter :keyword
  filter :gateway_ids, :as => 'select',
    :collection => proc { Gateway.all }, 
    :input_html => { :class => 'chosen' }
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    column :id, :sortable => :id do |x|
      link_to x.id, [:admin, x]
    end
    column :icon do |x|
      image_tag(x.icon.url(:thumb)) unless x.icon.blank?
    end
    column :provider_profile
    column :keyword
    column :title
    column :provider_gateways_count
    column :updated_at
    default_actions
  end

  #
  # SHOW
  #
  show do |provider|
    attributes_table do
      row :id
      row :provider_profile
      row :provider_group
      row :title
      row :keyword
      row :icon do
        image_tag(provider.icon) unless provider.icon.blank?
      end
      row :provider_gateways_count
      row :juristic_name
      row :inn
      row :updated_at
    end

    panel I18n.t('activerecord.models.gateway.other') do
      table_for(provider.provider_gateways.order("priority DESC"), :i18n => ProviderGateway) do |t|
        t.column :gateway
        t.column :priority
        t.column :gateway_provider_id
      end
    end

    panel I18n.t('activerecord.models.payment.other') do
      table_for(provider.payments.limit(20), :i18n => Payment) do |t|
        t.column :terminal do |p|
          unless p.terminal.blank?
            link_to p.terminal.keyword, admin_terminal_path(p.terminal)
          end
        end
        t.column :paid_amount
        t.column :provider
        t.column :created_at
      end
      button(
        link_to I18n.t('smartkiosk.full_list'),
        admin_payments_path(:q => {:provider_id_eq => provider.id})
      )
    end

    active_admin_comments
  end

  #
  # FORM
  #
  form do |f|
    f.inputs do
      f.input :title
      f.input :provider_profile, :input_html => { :class => 'chosen' },
        :collection => ProviderProfile.rmap
      f.input :provider_group, :input_html => { :class => 'chosen' }
      f.input :keyword
      f.input :icon, :hint => (f.template.image_tag(provider.icon).html_safe unless provider.icon.blank?)
      f.input :juristic_name
      f.input :inn
      f.input :requires_print, :as => :select, :input_html => { :class => 'chosen' }
    end
    f.inputs do
      f.has_many :provider_fields, :sortable => :priority do |fpf|
        fpf.input :title
        fpf.input :keyword,
          :hint => I18n.t('smartkiosk.admin.messages.provider_fields.keyword_hint')
        fpf.input :kind, :as => :select,
          :input_html => { 
            :class => 'chosen',
            :onchange => <<-JS
              element = $(this);
              wrapper = element.closest('ol');

              wrapper.find('.mask').hide();
              wrapper.find('.values').hide();

              if (element.val() == 'string' || element.val() == 'number') {
                wrapper.find('.mask').show();
              }
              if (element.val() == 'select') {
                wrapper.find('.values').show();
              }
            JS
          },
          :collection => I18n.t('smartkiosk.provider_field_kinds').invert
        fpf.input :mask, :as => :string,
          :wrapper_html => { 
            :class => 'mask',
            :style => ('display:none' unless fpf.object.kind == 'string')
          },
          :hint => I18n.t('smartkiosk.admin.messages.provider_fields.mask_hint')
        fpf.input :values, :as => :string,
          :wrapper_html => {
            :class => 'values',
            :style => ('display:none' unless fpf.object.kind == 'select')
          },
          :hint => I18n.t('smartkiosk.admin.messages.provider_fields.values_hint')
        fpf.input :priority, :as => :hidden
      end
    end
    f.inputs do
      f.has_many :provider_gateways do |fpg|
        fpg.input :gateway, :input_html => { :class => 'chosen' }
        fpg.input :gateway_provider_id
        fpg.input :priority
        fpg.input :account_mapping
        fpg.input :human_fields_mapping, :as => :text, :input_html => {:rows => 4}
        unless fpg.object.new_record?
          fpg.input :_destroy, :as => :boolean, :label => I18n.t('active_admin.delete')
        end
        fpg.form_buffers.last
      end
    end
    f.buttons
  end
end