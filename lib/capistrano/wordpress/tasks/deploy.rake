namespace :deploy do
  task :shared_configs do
    config_path = File.join(shared_path, "wp-config.php")
    robots_path = File.join(shared_path, "robots.txt")
    
    on roles(:app) do
      unless test("[ -f #{config_path} ]")
        invoke "config:generate"
      end
      
      unless test("[ -f #{robots_path} ]")
        invoke "robots:generate"
      end
    end
  end
  
  task :touch_release do
    on roles(:app) do |server|
      info "Touching release directory on #{server.user}@#{server.hostname}"
      
      execute :touch, release_path
    end
  end
end
