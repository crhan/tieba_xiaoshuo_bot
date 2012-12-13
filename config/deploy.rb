# -*- encoding : utf-8 -*-
require 'bundler/capistrano'
require 'sidekiq/capistrano'

set :application, "tieba_bot"
set :repository,  "https://github.com/crhan/tieba_xiaoshuo_bot"
set :scm, :git
set :deploy_to, "/home/crhan/app/bot"

server "home.crhan.com", :app, :web, :db, :primary => true
set :user, "crhan"
set :use_sudo, false

require 'capistrano-unicorn'

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

namespace :bot do
  task :start, :roles => :app do
    rails_env = fetch(:rails_env, 'production')
    run "cd #{current_path}; nohup #{fetch(:bundle_cmd, "bundle")} exec rake bot:run RAILS_ENV=#{rails_env} &>> #{current_path}/log/sidekiq.log &", :pty => false
  end

  task :stop, :roles => :app do
    run "if [ -d #{current_path} ] && [ -f #{pid_file} ]; then cd #{current_path} && kill `cat #{pid_file}`; fi"
  end

  task :restart, :roles => :app do
    stop
    start
  end
end

namespace :deploy do
  task :symlink_shared, :roles => :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/bot.yml #{release_path}/config/bot.yml"
  end
end

after 'deploy:update_code', 'deploy:symlink_shared'
after 'deploy:restart', 'unicorn:reload'
