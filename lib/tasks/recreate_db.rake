namespace :app do

  # Custom reset for developement environment
  desc "Reset"
  task :reset => :environment do
    if Rails.env.production?
      Rake::Task(:reset_production).invoke
    else
      Rake::Task(:reset_development).invoke
    end
  end

  desc "Reset development"
  task :reset_development => ["db:drop", "db:create", "db:migrate", "db:test:prepare", "db:seed"]

  desc "Reset production"
  task :reset_production => ["db:drop", "db:create", "db:migrate", "db:seed"]

end