require 'active_admin/cancan_integration'
require 'active_admin/views/pages/base_fix'
require 'active_admin/form_builder_fix'
require 'active_admin/resource_controller_fix'
require 'active_admin/inputs/filter_numeric_range_input'
require 'active_admin/inputs/filter_multiple_select_input'
require 'active_admin/inputs/filter_date_range_input_fix'
require 'paper_trail/version_fix'
require 'formtastic/inputs/selectable_check_boxes'
require 'dav4rack/build_resource'
require 'kaminari/array_extension_fix'

ActiveAdmin.setup do |config|
  # TODO: Remove this as soon as AA fixed
  I18n.locale = :ru
  I18n.load_path += Dir[File.expand_path("../../locales/**/*.yml", __FILE__)]
  I18n.reload!

  config.site_title = proc { I18n.t "smartkiosk.admin.title" }

  config.batch_actions = true

  config.namespace :admin do |admin_namespace|
    admin_namespace.root_to = "dashboard#index"
  end

  config.authentication_method = :authenticate_user!
  config.current_user_method = :current_user
  config.logout_link_path = :destroy_user_session_path

  config.register_javascript 'http://api-maps.yandex.ru/2.0-stable/?load=package.full&lang=ru-RU'
end