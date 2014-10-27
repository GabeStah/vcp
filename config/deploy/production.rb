set :stage, :production
set :rails_env, :production

server "#{fetch(:deploy_user)}@104.131.149.93", roles: %w{web app db}, primary: true