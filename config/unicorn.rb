# ------------------------------------------------------------------------------
# Sample rails 3 config
# ------------------------------------------------------------------------------

# Set your full path to application.
app_path = "/var/www/vcp/current"
shared_path = "/var/www/vcp/shared"

# Set unicorn options
worker_processes 1
preload_app true
timeout 180
listen "#{shared_path}/tmp/sockets/unicorn.sock"

# Spawn unicorn master worker for user apps (group: apps)
user 'rails', 'www-data'

# Fill path to your app
working_directory app_path

# Should be 'production' by default, otherwise use other env
rails_env = ENV['RAILS_ENV'] || 'production'

# Log everything to one file
stderr_path "#{shared_path}/log/unicorn.log"
stdout_path "#{shared_path}/log/unicorn.log"

# Set master PID location
pid "#{shared_path}/tmp/pids/unicorn.pid"

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end