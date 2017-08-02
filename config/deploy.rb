require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rvm'
require 'mina/deploy'
set :rails_env, 'production'
set :domain,     '46.101.216.217'
set :deploy_to,  "/home/deploy/app1/"
set :app_path,   "/home/deploy/app"
set :repository, 'https://github.com/Denisik/rails-test-app.git'
set :branch,     'master'
set :user, 'deploy'
set :port, '10022'
set :ssh_options, '-A'
task :environment do
invoke :'rvm:use', 'ruby 2.4.1@default'
end
task deploy: :environment do
  deploy do
    invoke :'git:clone'
    invoke :'server:stop_server'
    invoke :'sidekiq:stop'
    invoke :'bundle:install'
        on :launch do
          command "/home/deploy/app1/current/bin/yarn install --production"
          command "/home/deploy/app1/current/bin/webpack"
          invoke :'server:start_server'
          invoke :'sidekiq:start'
        end
    end
end
namespace :server do
  desc 'Stop server'
  task :stop_server do
    command 'echo "-----> Stop Server"'
    command 'kill -9 $(lsof -i :3000 -t) || true'
  end

  desc 'Start server'
  task :start_server do
    command 'echo "-----> Start Server"'
    command 'cd /home/deploy/app1/current && source ~/.rvm/scripts/rvm && rvm use ruby-2.4.1 && rails s -d'
  end
end

namespace :sidekiq do
  desc 'Stop sidekiq'
  task :stop do
    command 'echo "-----> Stop Sidekiq"'
    command 'kill -9 $(cat /home/deploy/app1/current/tmp/pids/sidekiq.pid) || true'
  end

  desc 'Start sidekiq'
  task :start do
    command 'echo "-----> Start Sidekiq"'
    command 'cd /home/deploy/app1/current && source ~/.rvm/scripts/rvm && rvm use ruby-2.4.1 && sidekiq -d'
  end
