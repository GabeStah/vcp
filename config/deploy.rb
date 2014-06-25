# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'VCP'

# Default value for :scm is :git
set :scm, :git
set :repo_url, 'git@github.com:GabeStah/vcp.git'
set :branch, 'master'

# Set the user for deployment
set :user, "deploy"

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/var/www/vcp'

# How to make updates
set :deploy_via, :copy

# Set environment
set :rails_env, "production"

# Default value for keep_releases is 5
set :keep_releases, 5

# Ensure ssh prompts appear
#default_run_options[:pty] = true

set :ssh_options, { forward_agent: true, user: fetch(:user) }

# Set temp directory
set :tmp_dir, "/home/deploy/tmp"

#RVM settings
#set :rvm_type, :user                     # Defaults to: :auto
#set :rvm_ruby_version, '2.0.0-p247'      # Defaults to: 'default'
#set :rvm_custom_path, '~/.myveryownrvm'  # only needed if not detected

# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
role :app, %w{gabestah.com}
role :web, %w{gabestah.com}
role :db,  %w{gabestah.com}

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server
# definition into the server list. The second argument
# is something that quacks like a hash and can be used
# to set extended properties on the server.
# server 'example.com', roles: %w{web app}, my_property: :my_value

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

namespace :deploy do
  desc 'Deploy the application'
  task :default do
    symlink_db_yml
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
      #run "touch #{ File.join(current_path, 'tmp', 'restart.txt') }"
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  desc "Symlink shared config files"
  task :symlink_config_files do
    run "ln -s #{ deploy_to }/shared/config/database.yml #{ current_path }/config/database.yml"
  end

  desc 'Set proper permissions'
  task :symlink_db_yml do
    #run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)

    # mkdir -p is making sure that the directories are there for some SCM's that don't
    # save empty folders
    # run <<-CMD
    #   rm -rf #{latest_release}/log #{latest_release}/public/system #{latest_release}/tmp/pids &&
    #   mkdir -p #{latest_release}/public &&
    #   mkdir -p #{latest_release}/tmp &&
    #   ln -s #{shared_path}/log #{latest_release}/log &&
    #   ln -s #{shared_path}/system #{latest_release}/public/system &&
    #   ln -s #{shared_path}/pids #{latest_release}/tmp/pids
    #   ln -sf #{shared_path}/config/database.yml #{latest_release}/config/database.yml
    # CMD

    on roles(:all) do |host|
      execute :ln, '-sf', "#{shared_path}/config/database.yml", "#{release_path}/config/database.yml"
    end
  end

end

#after "deploy:assets:precompile", "deploy:symlink_config_files"
#before "deploy:assets:precompile", "deploy:symlink_config_files"
before 'deploy:assets:precompile', 'deploy:symlink_db_yml'