# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'vcp'
set :repo_url, 'git@github.com:GabeStah/vcp.git'
set :rbenv_ruby, '2.1.3'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}
set :linked_files, %w{config/application.yml config/database.yml config/secrets.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :unicorn_config_path, "/var/www/vcp/current/config/unicorn.rb"
set :unicorn_pid, "/var/www/vcp/shared/tmp/pids/unicorn.pid"


namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')

    end
  end

  task :restart_unicorn do
    invoke 'unicorn:reload'
  end

  after 'deploy:publishing', 'deploy:restart_unicorn'

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end

      within release_path do
        execute :rake, "db:drop RAILS_ENV=production"
        execute :rake, "db:create RAILS_ENV=production"
        execute :rake, "db:migrate RAILS_ENV=production"
        execute :rake, "db:seed RAILS_ENV=production"
      end
    end
  end

end
