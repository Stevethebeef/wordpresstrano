namespace :deploy do
  task :all do
    Rake::Task["deploy"].prerequisites.delete("deploy:check_for_previous_deployment")
    Rake::Task["deploy:updated"].prerequisites.delete("htaccess:clone_from_previous_release")
    
    before "deploy", "deploy:shared_configs"
    
    after "deploy:updated", "htaccess:push"
    after "deploy:updated", "uploads:push"
    after "deploy:updated", "db:push"
    
    invoke "deploy"
  end
  
  task :check_for_previous_deployment do
    on roles(:all) do |server|
      unless test("[ -d #{current_path} ]")
        error "Unable to locate a current release on #{server.user}@#{server.hostname}"
        
        set :all_servers_have_deployments, false
      end
    end
    
    unless fetch(:all_servers_have_deployments, true)
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
  
  desc "Perform a safety check"
  task :safety_check do
    unless fetch(:website_root)
      raise "You must set the :website_root variable in your deployment configuration!"
    end
    
    if 1 < roles(:app).count
      raise "You can't deploy to more than one server!"
    end
    
    invoke "binaries:check"
    invoke "deploy:check:directories"
  end
  
  desc "Touch the most recent release directory on the remote servers"
  task :touch_release do
    on roles(:app) do |server|
      info "Touching release directory on #{server.user}@#{server.hostname}"
      
      execute :touch, release_path
    end
  end
end
