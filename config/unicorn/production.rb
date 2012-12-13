worker_processes 1
preload_app true
timeout 60
listen "127.0.0.1:8001"

rails_env = ENV["RAILS_ENV"] || 'production'

stderr_path "log/unicorn.err.log"
stdout_path "log/unicorn.out.log"
