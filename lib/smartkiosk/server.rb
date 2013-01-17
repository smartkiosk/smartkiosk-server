require 'rails/engine'

module Smartkiosk
  module Server
    VERSION = File.read(File.expand_path '../../../VERSION', __FILE__).strip

    def self.revision
      file = File.expand_path '../../../REVISION'
      File.exist?(file) ? File.read(file).strip : nil
    end

    class Engine < ::Rails::Engine
      initializer 'matrioshka', :before => :set_autoload_paths do |app|

        # Rails
        app.class.configure do
          config.i18n.load_path += Dir[Smartkiosk::Server::Engine.root.join(*%w(config locales *.{rb,yml})).to_s]
          config.autoload_paths += %W(#{Smartkiosk::Server::Engine.root.join 'lib'})
          config.paths['db/migrate'] += Smartkiosk::Server::Engine.paths['db/migrate'].existent
        end

        # ActiveAdmin
        ActiveAdmin.setup do |config|
          config.load_paths << Smartkiosk::Server::Engine.root.join('app/admin')
        end

        # TODO: Remove this as soon as AA fixed
        config.after_initialize do
          I18n.reload!
        end
      end
    end
  end
end
