role :web, "smartkiosk-dev1.rdlk.net"
role :app, "smartkiosk-dev1.rdlk.net"
role :db,  "smartkiosk-dev1.rdlk.net", :primary => true

set :use_sudo, false
set :user, "deployer"

set :deploy_to, "/home/deployer/www/#{application}"

before 'deploy:assets:precompile', 'deploy:configure'
before 'deploy:create_symlink', 'deploy:install'