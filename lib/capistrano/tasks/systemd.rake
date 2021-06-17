git_plugin = self

namespace :sneakers do
  desc 'Quiet sneakers'
  task :quiet do
    on roles fetch(:sneakers_roles) do |role|
      git_plugin.switch_user(role) do
        if fetch(:sneakers_service_unit_user) == :system
          execute :sudo, :systemctl, "reload", fetch(:sneakers_service_unit_name), raise_on_non_zero_exit: false
        else
          execute :systemctl, "--user", "reload", fetch(:sneakers_service_unit_name), raise_on_non_zero_exit: false
        end
      end
    end
  end

  desc 'Stop sneakers (graceful shutdown within timeout)'
  task :stop do
    on roles fetch(:sneakers_roles) do |role|
      git_plugin.switch_user(role) do
        if fetch(:sneakers_service_unit_user) == :system
          execute :sudo, :systemctl, "stop", fetch(:sneakers_service_unit_name)
        else
          execute :systemctl, "--user", "stop", fetch(:sneakers_service_unit_name)
        end
      end
    end
  end

  desc 'Start sneakers'
  task :start do
    on roles fetch(:sneakers_roles) do |role|
      git_plugin.switch_user(role) do
        if fetch(:sneakers_service_unit_user) == :system
          execute :sudo, :systemctl, 'start', fetch(:sneakers_service_unit_name)
        else
          execute :systemctl, '--user', 'start', fetch(:sneakers_service_unit_name)
        end
      end
    end
  end

  desc 'Install systemd sneakers service'
  task :install do
    on roles fetch(:sneakers_roles) do |role|
      git_plugin.switch_user(role) do
        git_plugin.create_systemd_template
        if fetch(:sneakers_service_unit_user) == :system
          execute :sudo, :systemctl, "enable", fetch(:sneakers_service_unit_name)
        else
          execute :systemctl, "--user", "enable", fetch(:sneakers_service_unit_name)
          execute :loginctl, "enable-linger", fetch(:sneakers_lingering_user) if fetch(:sneakers_enable_lingering)
        end
      end
    end
  end

  desc 'UnInstall systemd sneakers service'
  task :uninstall do
    on roles fetch(:sneakers_roles) do |role|
      git_plugin.switch_user(role) do
        if fetch(:sneakers_service_unit_user) == :system
          execute :sudo, :systemctl, "disable", fetch(:sneakers_service_unit_name)
        else
          execute :systemctl, "--user", "disable", fetch(:sneakers_service_unit_name)
        end
        execute :rm, '-f', File.join(fetch(:service_unit_path, fetch_systemd_unit_path), fetch(:sneakers_service_unit_name))
      end
    end
  end

  desc 'Generate service_locally'
  task :generate_service_locally do
    run_locally do
      File.write('sneakers', git_plugin.compiled_template)
    end
  end

  def fetch_systemd_unit_path
    if fetch(:sneakers_service_unit_user) == :system
      # if the path is not standard `set :service_unit_path`
      "/etc/systemd/system/"
    else
      home_dir = backend.capture :pwd
      File.join(home_dir, ".config", "systemd", "user")
    end
  end

  def compiled_template
    search_paths = [
      File.expand_path(
          File.join(*%w[.. .. .. generators capistrano sneakers systemd templates sneakers.service.capistrano.erb]),
          __FILE__
      ),
    ]
    template_path = search_paths.detect { |path| File.file?(path) }
    template = File.read(template_path)
    ERB.new(template).result(binding)
  end

  def create_systemd_template
    ctemplate = compiled_template
    systemd_path = fetch(:service_unit_path, fetch_systemd_unit_path)

    if fetch(:sneakers_service_unit_user) == :user
      backend.execute :mkdir, "-p", systemd_path
    end
    backend.upload!(
        StringIO.new(ctemplate),
        "/tmp/#{fetch :sneakers_service_unit_name}.service"
    )
    if fetch(:sneakers_service_unit_user) == :system
      backend.execute :sudo, :mv, "/tmp/#{fetch :sneakers_service_unit_name}.service", File.join(systemd_path, "#{fetch :sneakers_service_unit_name}.service")
      backend.execute :sudo, :systemctl, "daemon-reload"
    else
      backend.execute :mv, "/tmp/#{fetch :sneakers_service_unit_name}.service", File.join(systemd_path, "#{fetch :sneakers_service_unit_name}.service")
      backend.execute :systemctl, "--user", "daemon-reload"
    end
  end
end