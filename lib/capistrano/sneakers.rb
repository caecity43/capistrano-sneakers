require 'capistrano/bundler'
require "capistrano/plugin"

module Capistrano
  class Sneakers < Capistrano::Plugin
    def define_tasks
      eval_rakefile File.expand_path('../tasks/sneakers.rake', __FILE__)
    end

    def set_defaults
      set_if_empty :sneakers_default_hooks, true

      set_if_empty :sneakers_env, -> { fetch(:rack_env, fetch(:rails_env, fetch(:rake_env, fetch(:stage)))) }
      set_if_empty :sneakers_roles, fetch(:sneakers_role, :app)
      set_if_empty :sneakers_log, -> { File.join(shared_path, 'log', 'sneakers.log') }
      set_if_empty :sneakers_error_log, -> { File.join(shared_path, 'log', 'sneakers.error.log') }
      set_if_empty :sneakers_pid, -> { File.join(shared_path, 'tmp', 'pids', 'sneakers.pid') }
      set_if_empty :sneakers_start_timeout, fetch(:sneakers_start_timeout) || 5
      set_if_empty :sneakers_processes, 1
      set_if_empty :sneakers_workers, false # if this is false it will cause Capistrano to exit
      set_if_empty :sneakers_run_config, true # if this is true sneakers will run with preconfigured /config/initializers/sneakers.rb
      set_if_empty :rbenv_map_bins, fetch(:rbenv_map_bins).to_a.concat(%w(sneakers))
      set_if_empty :rvm_map_bins, fetch(:rvm_map_bins).to_a.concat(%w(sneakers))
    end
  end
end

require_relative 'sneakers/helpers'
require_relative 'sneakers/systemd'
require_relative 'sneakers/monit'