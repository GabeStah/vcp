namespace :app do

  desc "Reset"
  task :reset => ["db:drop", "db:create", "db:migrate", "db:test:prepare", "db:seed"]

end