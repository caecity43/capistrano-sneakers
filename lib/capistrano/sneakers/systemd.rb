module Capistrano
  class Sneakers::Systemd < Capistrano::Plugin
    include Sneakers::Helpers

    def set_defaults
      set_if_empty :sneakers_service_unit_name, 'sneakers'
      set_if_empty :sneakers_service_unit_user, :user # :system
      set_if_empty :sneakers_enable_lingering, true
      set_if_empty :sneakers_lingering_user, nil
    end

    def define_tasks
      eval_rakefile File.expand_path('../../tasks/systemd.rake', __FILE__)
    end
  end
end