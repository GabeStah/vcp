require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina_sidekiq/tasks'
# require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
# require 'mina/rvm'    # for rvm support. (http://rvm.io)

set :domain, '104.131.149.93'
set :deploy_to, '/var/www/vcp'
set :repository, 'https://github.com/GabeStah/vcp.git'
set :branch, 'master'

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, ['config/database.yml', 'log', 'pids']

# Optional settings:
set :user, 'rails'    # Username in the server to SSH to.
#   set :port, '30000'     # SSH port number.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do

end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[mkdir -p "#{deploy_to}/shared/pids"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/pids"]

  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
  queue  %[echo "-----> Be sure to edit 'shared/config/database.yml'."]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    # stop accepting new workers
    invoke :'sidekiq:quiet'
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :reset_db

    to :launch do
      invoke :restart_rails
      invoke :'sidekiq:restart'
    end
  end
end

desc "Resetting Database"
task :reset_db do
  queue 'rake app:reset_production RAILS_ENV=production'
end

desc "Restart Rails"
task :restart_rails do
  queue! %[mkdir -p "#{deploy_to}/#{current_path}/tmp"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{current_path}/tmp"]
  queue "touch #{deploy_to}/#{current_path}/tmp/restart.txt"
end