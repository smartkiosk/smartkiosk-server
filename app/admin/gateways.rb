ActiveAdmin.register Gateway do
  actions :index, :show, :edit, :update

  menu :parent   => I18n.t('activerecord.models.gateway.other'), 
       :label    => I18n.t('smartkiosk.admin.menu.manage'), 
       :priority => 1,
       :if       => proc { can? :index, Gateway }

  member_action :providers do
    @gateway   = Gateway.find(params[:id])
    @providers = @gateway.librarize.providers
  end

  #
  # INDEX
  #
  batch_action I18n.t('smartkiosk.admin.actions.gateways.enable') do |selection|
    Gateway.find(selection).each do |p|
      p.update_attribute(:enabled, true)
    end

    redirect_to :action => :index
  end

  batch_action I18n.t('smartkiosk.admin.actions.gateways.disable') do |selection|
    Gateway.find(selection).each do |p|
      p.update_attribute(:enabled, false)
    end

    redirect_to :action => :index
  end

  filter :title
  filter :keyword
  filter :debug_level, :as => 'multiple_select',
    :collection => proc { I18n.t('smartkiosk.debug_levels').invert }, 
    :input_html => { :class => 'chosen' }
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    column :title, :sortable => :title do |x|
      link_to x.title, [:admin, x]
    end
    column :keyword
    column :enabled do |x|
      if x.enabled?
        status_tag I18n.t('formtastic.yes'), 'ok'
      else
        status_tag I18n.t('fomtastic.no'), 'error'
      end
    end
    column :updated_at
    default_actions
  end

  #
  # SHOW
  #
  action_item :only => [:show] do
    link_to I18n.t('smartkiosk.admin.actions.gateways.pay'), 
      new_admin_payment_path(:payment => {:gateway_id => gateway.id})
  end

  action_item :only => [:show], :if => proc { gateway.librarize.can_list_providers? } do
    link_to I18n.t('smartkiosk.admin.actions.gateways.providers'),
      providers_admin_gateway_path(gateway)
  end

  show do
    attributes_table do
      row :title
      row :keyword
      row :created_at
    end

    panel I18n.t('smartkiosk.admin.panels.gateways.settings') do
      div(:class => 'attributes_table') do
        table do
          gateway.available_switches.each do |s|
            tr do
              th do
                I18n.t("smartkiosk.gateways.#{gateway.keyword}.switches.#{s}")
              end
              td do
                if gateway.send("switch_#{s}")
                  I18n.t('formtastic.yes')
                else
                  span(I18n.t('formtastic.no'), :class => 'empty')
                end
              end
            end
          end
          gateway.available_settings.each do |s|
            tr do
              th do
                I18n.t("smartkiosk.gateways.#{gateway.keyword}.settings.#{s}")
              end
              td do
                value = gateway.send("setting_#{s}")
                unless value.blank?
                  value
                else
                  span(I18n.t('active_admin.empty'), :class => 'empty')
                end
              end
            end
          end
          gateway.available_attachments.each do |a|
            tr do
              th do
                I18n.t("smartkiosk.gateways.#{gateway.keyword}.attachments.#{a}")
              end
              td do
                value = gateway.send("attachment_#{a}")
                unless value.blank?
                  link_to value.path.split('/').last, value.url
                else
                  span(I18n.t('active_admin.empty'), :class => 'empty')
                end
              end
            end
          end
        end
      end
    end

    panel I18n.t('activerecord.models.payment.other') do
      table_for(gateway.payments.limit(20), :i18n => Payment) do |t|
        t.column :terminal do |p|
          unless p.terminal.blank?
            link_to p.terminal.keyword, admin_terminal_path(p.terminal)
          end
        end
        t.column :paid_amount
        t.column :provider
        t.column :created_at
      end
      button(link_to I18n.t('smartkiosk.full_list'), admin_payments_path(:q => {:gateway_id_eq => gateway.id}))
    end

    active_admin_comments
  end

  #
  # FORM
  #
  form do |f|
    f.inputs I18n.t('smartkiosk.admin.panels.gateways.settings') do
      f.input :debug_level, :as => :select, 
        :collection => I18n.t("smartkiosk.debug_levels").invert, :input_html => {:class => 'chosen'}

      f.input :requires_revisions_moderation, :as => :select, :input_html => {:class => 'chosen'}

      gateway.available_switches.each do |s|
        f.input "switch_#{s}", :as => :select,
          :label => I18n.t("smartkiosk.gateways.#{gateway.keyword}.switches.#{s}"),
          :input_html => {:value => f.object.send("switch_#{s}"), :class => 'chosen'}
      end

      gateway.available_settings.each do |s|
        f.input "setting_#{s}", :as => :string,
          :label => I18n.t("smartkiosk.gateways.#{gateway.keyword}.settings.#{s}"),
          :input_html => {:value => f.object.send("setting_#{s}")}
      end

      gateway.available_attachments.each do |a|
        file = f.object.send(:"attachment_#{a}")

        f.input "attachment_#{a}",
          :label => I18n.t("smartkiosk.gateways.#{gateway.keyword}.attachments.#{a}"), :as => :file,
          :hint => (f.template.link_to(file.path.split('/').last).html_safe unless file.blank?)
      end

      f.input :enabled, :as => :select, :input_html => {:class => 'chosen'}

      f.form_buffers.last
    end

    f.actions
  end
end
