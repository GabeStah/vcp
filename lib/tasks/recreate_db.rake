namespace :app do

  desc "Reset development"
  task :reset_development => ["db:drop", "db:create", "db:migrate", "db:test:prepare", "db:seed"]

  desc "Reset production"
  task :reset_production => ["db:drop", "db:create", "db:migrate", "db:seed"]

  # Custom reset for developement environment
  desc "Reset"
  task :reset => :environment do
    if Rails.env.production?
      Rake::Task('app:reset_production').invoke
    else
      Rake::Task('app:reset_production').invoke
    end
  end

end