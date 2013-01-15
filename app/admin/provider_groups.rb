ActiveAdmin.register ProviderGroup do
  menu :parent => I18n.t('activerecord.models.provider.other'),
       :if     => proc { can? :index, ProviderGroup },
       :priority => 2

  #
  # INDEX
  #
  filter :id
  filter :title
  filter :provider_group, :input_html => { :class => 'chosen' }

  index do
    selectable_column
    column :id do |x|
      link_to x.id, [:admin, x]
    end
    column :icon do |x|
      image_tag(x.icon.url(:thumb)) unless x.icon.blank?
    end
    column :title
    column :provider_group
    column :created_at
    column :updated_at
    default_actions
  end

  #
  # SHOW
  #
  show do |provider_group|
    attributes_table do
      row :id
      row :title
      row :icon do
        image_tag(provider_group.icon) unless provider_group.icon.blank?
      end
      row :provider_group
      row :created_at
      row :updated_at
    end
  end

  #
  # FORM
  #
  form do |f|
    f.inputs do
      f.input :title
      f.input :provider_group, :input_html => { :class => 'chosen' },
        :collection => ProviderGroup.tree(f.object)
      f.input :icon, :hint => (
          unless provider_group.icon.blank?
            f.template.image_tag(provider_group.icon).html_safe
          end
        )
    end
    f.actions
  end
end
