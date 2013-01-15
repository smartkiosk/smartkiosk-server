role :web, "smartkiosk-dev4.rdlk.net"
role :app, "smartkiosk-dev4.rdlk.net"
role :db,  "smartkiosk-dev4.rdlk.net", :primary => true

set :use_sudo, false
set :user, "deployer"

set :deploy_to, "/home/deployer/www/#{application}"

before 'deploy:assets:precompile', 'deploy:configure'
before 'deploy:create_symlink', 'deploy:install'