ActiveAdmin.register SystemReceiptTemplate do
  config.batch_actions = false
  
  actions :index, :show, :edit

  menu :parent   => I18n.t('activerecord.models.terminal.other'),
       :priority => 30,
       :if       => proc { can? :index, SystemReceiptTemplate }

  #
  # INDEX
  #
  filter :keyword, :as => 'multiple_select', 
    :collection => proc { I18n.t('smartkiosk.system_receipt_templates').invert },
    :input_html => { :class => 'chosen' }
  filter :updated_at

  index do
    column :keyword do |x|
      x.title
    end
    column :updated_at
    column '' do |resource|
      links = []

      links << link_to(
        I18n.t('active_admin.view'), resource_path(resource),
        :class => 'member_link view_link'
      )

      links << link_to(
        I18n.t('active_admin.edit'), edit_resource_path(resource),
        :class => 'member_link view_link'
      )

      if can?(:destroy, resource)
        links << link_to(
          I18n.t('active_admin.delete'), resource_path(resource),
          :class  => 'member_link view_link',
          :method => :delete
        )
      end

      links.join(' ').html_safe
    end
  end

  #
  # SHOW
  #
  show do |rt|
    attributes_table do
      row :keyword do
        rt.title
      end
      row :template do
        pre rt.template
      end
      row :updated_at
    end

    active_admin_comments
  end

  #
  # FORM
  #
  form do |f|
    f.inputs do
      f.input :template, :input_html => { 
        :style => 'font-family: Consolas, Monaco, Lucida Console, Liberation Mono, DejaVu Sans Mono, Bitstream Vera Sans Mono, Courier New, monospace' 
      }
    end
    f.actions
  end
end
