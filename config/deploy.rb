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
    invoke :'bundle:install'
        on :launch do
          command  "touch /home/deploy/app1/tmp/restart.txt"
          command "/home/deploy/app1/current/bin/yarn install --production"
          command "/home/deploy/app1/current/bin/webpack"
          command "touch #{deploy_to}/tmp/restart.txt"
        end
    end
end
