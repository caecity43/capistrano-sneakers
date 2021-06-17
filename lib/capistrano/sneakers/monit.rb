# Load monit tasks
load File.expand_path('../../tasks/monit.rake', __FILE__)

module Capistrano
  class Sneakers::Monit < Capistrano::Plugin

    def set_defaults
      set_if_empty :monit_bin, '/usr/bin/monit'
      set_if_empty :sneakers_monit_conf_dir, '/etc/monit/conf.d'
      set_if_empty :sneakers_monit_conf_file, -> { "#{sneakers_service_name}.conf" }
      set_if_empty :sneakers_monit_use_sudo, true
      set_if_empty :sneakers_monit_default_hooks, true
      set_if_empty :sneakers_monit_templates_path, 'config/deploy/templates'
      set_if_empty :sneakers_monit_group, nil
    end

    def define_tasks
      eval_rakefile File.expand_path('../../tasks/monit.rake', __FILE__)
    end
  end
end