namespace :deploy do
  task :check_for_previous_deployment do
    previous_deployment = true
    
    on roles(:all) do |server|
      unless test("[ -d #{current_path} ]")
        error "Unable to locate a current release on #{server.user}@#{server.hostname}"
        
        previous_deployment = false
      end
    end
    
    unless previous_deployment
      raise "One or more servers don't have a current release on them. You should run 'deploy:all' first."
    end
  end
  
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
