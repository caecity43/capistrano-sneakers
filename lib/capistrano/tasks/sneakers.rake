namespace :deploy do
  before :starting, :check_sneakers_hooks do
    invoke 'sneakers:add_default_hooks' if fetch(:sneakers_default_hooks)
  end

  after :publishing, :restart_sneakers do
    invoke 'sneakers:restart' if fetch(:sneakers_default_hooks)
  end
end

namespace :sneakers do
  task :add_default_hooks do
    after 'deploy:starting',  'sneakers:quiet'
    after 'deploy:updated',   'sneakers:stop'
    after 'deploy:reverted',  'sneakers:stop'
    after 'deploy:published', 'sneakers:start'
    after 'deploy:failed', 'sneakers:restart'
  end

  desc 'Restart sneakers'
  task :restart do
    invoke! 'sneakers:stop'
    invoke! 'sneakers:start'
  end

end
