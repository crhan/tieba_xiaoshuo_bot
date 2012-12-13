# -*- encoding : utf-8 -*-
require 'bundler/capistrano'

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

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end

namespace :deploy do
  task :symlink_shared, :roles => :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/bot.yml #{release_path}/config/bot.yml"
  end
end

after 'deploy:update_code', 'deploy:symlink_shared'
after 'deploy:restart', 'unicorn:reload'
after 'deploy:restart', 'unicorn:restart'
