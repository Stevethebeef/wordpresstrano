namespace :db do
  desc "Push up the WordPress database"
  task :push do
    file = "#{SecureRandom.hex(8)}.sql"
    
    local_path = File.join(Dir.pwd, file)
    remote_path = File.join(fetch(:tmp_dir), file)
    
    on roles(:db) do |server|
      info "Pushing WordPress database to #{server.user}@#{server.hostname}"
      
      run_locally do
        execute :wp, "db", "export", local_path
      end
      
      upload! local_path, remote_path
      
      run_locally do
        execute :rm, "-f", local_path
      end
      
      within release_path do
        execute :wp, "db", "import", remote_path
        execute :rm, "-f", remote_path
        
        if fetch(:local_site_url) and fetch(:site_url)
          execute :wp, "search-replace", fetch(:local_site_url), fetch(:site_url)
        end
      end
    end
  end
  
  desc "Create the MySQL database"
  task :create do
    database_config = fetch(:database_config)
    
    unless database_config.has_keys? :hostname, :username, :database, :password
      abort "The #{fetch(:stage)} database configuration is invalid"
    end
    
    database_name = database_config[:database]
    database_hostname = database_config[:hostname]
    database_username = database_config[:username]
    database_password = database_config[:password]
    
    on roles(:db) do |server|
      within release_path do
        if test("[ \"#{database_name}\" == $(mysqlshow --user=\"#{database_username}\" --password=\"#{database_password}\" #{database_name} | grep -v Wildcard | grep -o #{database_name}) ]")
          info "The MySQL database already exists on #{server.user}@#{server.hostname}"
          
          next
        end
        
        info "Creating MySQL database on #{server.user}@#{server.hostname}"
        
        execute :wp, "db", "create"
      end
    end
  end
end