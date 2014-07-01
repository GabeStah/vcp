namespace :app do

  # Custom reset for developement environment
  desc "Reset"
  task :reset => :environment do
    if Rails.env.production?
      Rake::Task["db:drop", "db:create", "db:migrate", "db:seed"]
    else
      Rake::Task["db:drop", "db:create", "db:migrate", "db:test:prepare", "db:seed"]
    end
  end

end