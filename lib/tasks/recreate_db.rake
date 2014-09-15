namespace :app do

  desc "Reset"
  task :reset => ["db:drop", "db:create", "db:migrate", "db:test:prepare", "db:seed"]

  desc "Reset Production"
  task :reset_production => ["db:drop", "db:create", "db:migrate", "db:seed"]

end