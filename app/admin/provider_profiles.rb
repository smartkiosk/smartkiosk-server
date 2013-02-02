ActiveAdmin.register ProviderProfile do
  menu :parent => I18n.t('activerecord.models.provider.other'),
       :if     => proc { can? :index, ProviderProfile },
       :priority => 3

  filter :providers_id, :as => 'multiple_select', :input_html => { :class => 'chosen' }, 
    :collection => proc { Provider.rmap }
  filter :title
  filter :created_at
  filter :updated_at
end
