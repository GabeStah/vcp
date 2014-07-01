require 'capistrano/sidekiq'
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

set :ssh_options, { forward_agent: true, user: fetch(:user) }

# Set temp directory
set :tmp_dir, "/home/deploy/tmp"

# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
role :app, %w{gabestah.com}
role :web, %w{gabestah.com}
role :db,  %w{gabestah.com}

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, current_path.join('tmp/restart.txt')
    end
  end

  desc "Recreate the database."
  task :recreate_db do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: :production do
          execute :rake, "db:drop"
          execute :rake, "db:create"
        end
      end
    end
  end

  desc "Seed the database."
  task :seed_db do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: :production do
          execute :rake, 'db:seed'
        end
      end
    end
  end

  desc 'Create database.yml symlink'
  task :symlink_db_yml do
    on roles(:all) do
      execute :ln, '-sf', "#{shared_path}/config/database.yml", "#{release_path}/config/database.yml"
    end
  end

  desc 'Upload database.yml'
  task :upload_db_yml do
    run_locally do
      execute :scp, '~/dev/projects/vcp/config/database.yml', 'deploy@gabestah.com:/var/www/vcp/shared/config/database.yml'
    end
  end

  before :started, :upload_db_yml

  after :publishing, :restart
  #after :publishing, :seed_db
  after :restart, :seed_db
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end

# Update symlink after release path is generated
before 'deploy:assets:precompile', 'deploy:symlink_db_yml'
after 'deploy:assets:precompile', 'deploy:recreate_db'