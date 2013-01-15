require 'bundler/capistrano'
require 'sidekiq/capistrano'
require 'capistrano/ext/multistage'

set :stages, %w(roundlake-passenger roundlake-trinidad mkb mkb-test)
set :default_stage, 'roundlake-passenger'
set :application, 'smartkiosk'

on :start do
  set :rails_env, 'production'
end

set :repository,  'git@github.com:roundlake/smartkiosk-server.git'

set :keep_releases, 1


namespace :deploy do
  task :configure do
    run "ln -f #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end

  task :install do
    run "cd #{release_path}; bundle exec rake db:install RAILS_ENV=#{rails_env} SEED_TEST=true"
  end

  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end
