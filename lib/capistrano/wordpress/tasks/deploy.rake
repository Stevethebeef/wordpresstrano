namespace :deploy do
  task :resources do
    #set :database_backup_time, Time.now.strftime("%Y%m%d%H%M%S")
    
    #set :confirm_push_database, true
    
    on roles(:app) do
      #config_path = File.join(shared_path, "wp-config.php")
      robots_path = File.join(shared_path, "robots.txt")
      
      #if test("[ -d #{release_path} ]")
      #  within release_path do
      #    if test :wp, "core", "is-installed"
      #      before "db:push", "db:backup:new"
      #    end
      #  end
      #end
      
      #unless test("[ -f #{config_path} ]")
      #  invoke "config:generate"
      #end
      
      unless test("[ -f #{robots_path} ]")
        invoke "robots:generate"
      end
      
      #invoke "htaccess:push"
      #invoke "uploads:push"
    end
  end
end
