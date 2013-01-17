require 'rails/engine'
require 'activeadmin'
require 'activeadmin-cancan'

module Smartkiosk
  module Server
    VERSION = '0.0.1'

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
        
      end
    end
  end
end
