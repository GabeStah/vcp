namespace :app do

  # Custom reset for developement environment
  desc "Reset"
  task :reset => ["db:drop", "db:create", "db:migrate", "db:test:prepare", "db:seed"]

end