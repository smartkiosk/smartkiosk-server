ActiveAdmin.register ProviderProfile do
  menu :parent => I18n.t('activerecord.models.provider.other'),
       :if     => proc { can? :index, ProviderProfile },
       :priority => 3
end
