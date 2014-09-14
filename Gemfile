source 'https://rubygems.org'
ruby '2.1.1'

gem 'rails', '4.1.1'
gem 'mysql2'
gem 'bootstrap-sass', '2.3.2.0'
gem 'sprockets', '2.11.0'
gem 'bcrypt-ruby', '3.1.2'
gem 'faker', '1.1.2'
gem 'sidekiq', github: 'mperham/sidekiq'
gem 'sidekiq-failures'
gem 'sidetiq'
# Enabled for Sidekiq frontend
gem 'sinatra', '>= 1.3.0', :require => nil
gem 'attribute_normalizer'
# For copy capabilities
gem 'zeroclipboard-rails'
# For tooltip capabilities
gem 'tipsy-rails'
# Used for chaining OR queries, see: https://github.com/oelmekki/activerecord_any_of
gem 'activerecord_any_of'
# Used to allow history and revert actions
gem 'paper_trail'
# Boostrap datetime picker
gem 'momentjs-rails'
gem 'bootstrap3-datetimepicker-rails'
# Time validation
gem 'validates_timeliness'
# Datagrid creation
#gem 'wice_grid', '3.4.9'
# Editing out paginate for wice_grid
gem 'will_paginate', '3.0.4'
gem 'bootstrap-will_paginate', '0.0.9'
gem 'jquery-ui-rails'
# DataTables
gem 'jquery-datatables-rails', '~> 2.2.1'
# Ajax DataTables integration
gem 'ajax-datatables-rails', github: 'antillas21/ajax-datatables-rails'
# Settings
gem 'settingslogic'

group :development, :test do
  gem 'rspec-rails'
  # The following optional lines are part of the advanced setup.
  # gem 'guard-rspec'
  gem 'spork-rails'
  # gem 'guard-spork'
  gem 'childprocess'
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
  gem 'capistrano-sidekiq' , github: 'seuros/capistrano-sidekiq'
  gem 'launchy'
  gem 'quiet_assets'
  # Help with n+1
  gem 'bullet'
end

group :test do
  gem 'selenium-webdriver'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'cucumber-rails', '1.4.0', :require => false
  gem 'database_cleaner', github: 'bmabey/database_cleaner'
  gem 'rspec-its'

  # Uncomment this line on OS X.
  # gem 'growl', '1.0.3'

  # Uncomment these lines on Linux.
  # gem 'libnotify', '0.8.0'

  # Uncomment these lines on Windows.
  #gem 'rb-notifu', '0.0.4'
  #gem 'win32console', '1.3.2'
  #gem 'wdm', '0.1.0'
end

gem 'sass-rails', '~> 4.0.0'
gem 'uglifier', '2.1.1'
gem 'coffee-rails', '4.0.1'
gem 'jquery-rails', '3.0.4'
gem 'turbolinks', '1.1.1'
gem 'jbuilder', '1.0.2'
gem 'best_in_place', github: 'bernat/best_in_place'

group :doc do
  gem 'sdoc', '0.3.20', require: false
end

group :production do
  gem 'rails_12factor'
end