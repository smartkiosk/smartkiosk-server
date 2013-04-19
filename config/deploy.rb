require 'bundler/capistrano'
require 'sidekiq/capistrano'
require 'capistrano/ext/multistage'

set :stages, %w(roundlake-passenger roundlake-trinidad mkb mkb-test)
set :default_stage, 'roundlake-passenger'
set :application, 'smartkiosk'

on :start do
  set :rails_env, 'production'
end

set :repository,  'git@github.com:smartkiosk/smartkiosk-server.git'

set :keep_releases, 1

set :use_sudo, false
set :user, "deployer"

set :deploy_to, "/home/deployer/www/#{application}"

after 'deploy:update_code', 'deploy:configure'
before 'deploy:create_symlink', 'deploy:install' if ENV['DEPLOY_DB']

namespace :deploy do
  task :configure do
    run "ln -f #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end

  task :install do
    run "cd #{current_path}; bundle exec rake db:install RAILS_ENV=#{rails_env} SEED_TEST=true"
  end

  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end
