namespace :db do
  desc "Pull down the WordPress database"
  task :pull do
    file = "#{SecureRandom.hex(8)}.sql"
    
    local_path = File.join(Dir.pwd, file)
    remote_path = File.join(fetch(:tmp_dir), file)
    
    next if 0 == roles(:db).count
    
    if 1 < roles(:db).count
      run_locally do
        info "Found #{roles(:db).count} database servers"
        
        roles(:db).each_with_index do |server, index|
          info "#{index + 1}) #{server.user}@#{server.hostname} (Port #{server.port or 22})"
        end
        
        set :database_pull_server, ask("the number of the server to pull the database from", "1")
      end
    else
      set :database_pull_server, "1"
    end
    
    database_pull_server = fetch(:database_pull_server).to_i
    
    if 1 > database_pull_server or roles(:db).count < database_pull_server
      run_locally do
        error "Unable to locate a server with an id '#{database_pull_server}'"
      end
      
      next
    end
    
    database_pull_server = roles(:db)[database_pull_server - 1]
    
    on roles(:db) do |server|
      next unless server.matches? database_pull_server
      
      info "Pulling WordPress database from #{server.user}@#{server.hostname}"
      
      within release_path do
        execute :wp, "db", "export", remote_path
      end
      
      download! remote_path, local_path
      
      execute :rm, "-f", remote_path
      
      run_locally do
        execute :wp, "db", "import", local_path
        execute :rm, "-f", local_path
        
        if fetch(:local_site_url) and fetch(:site_url)
          execute :wp, "search-replace", fetch(:site_url), fetch(:local_site_url)
        end
      end
    end
    
    set :database_pull_server, nil
  end
  
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
  
  desc "Drop the MySQL database"
  task :drop do
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
        unless test("[ \"#{database_name}\" == $(mysqlshow --user=\"#{database_username}\" --password=\"#{database_password}\" #{database_name} | grep -v Wildcard | grep -o #{database_name}) ]")
          info "The MySQL database does not exist on #{server.user}@#{server.hostname}"
          
          next
        end
        
        info "Deleting MySQL database on #{server.user}@#{server.hostname}"
        
        execute :wp, "db", "drop", "--yes"
      end
    end
  end
  
  desc "Reset the MySQL database"
  task :reset do
    on roles(:db) do |server|
      within release_path do
        unless test :wp, "core", "is-installed"
          info "The WordPress database does not appear to be installed on #{server.user}@#{server.hostname}"
          
          next
        end
        
        info "Resetting the WordPress database on #{server.user}@#{server.hostname}"
        
        execute :wp, "db", "reset", "--yes"
      end
    end
  end
  
  desc "Create a backup of the WordPress database"
  task :backup do
    backups_directory = File.join(fetch(:deploy_to), "backups", "database")
    
    on roles(:db) do |server|
      next unless test("[ -d #{current_path} ]")
      
      actual_current_path = capture("readlink -f #{current_path}").strip
      
      file = File.basename(actual_current_path)
      file = "#{file}.sql"
    
      remote_path = File.join(backups_directory, file)
      
      info "Backing up WordPress database on #{server.user}@#{server.hostname}"
      
      execute :mkdir, "-p", backups_directory
      
      if test("[ -f #{remote_path} ]")
        execute :rm, "-f", remote_path
      end
      
      within release_path do
        execute :wp, "db", "export", remote_path
      end
    end
  end
  
  # Enable maintenance mode if WordPress is already installed (used by db:push)
  task :check_maintenance_enable do
    on roles(:db) do
      next unless test("[ -d #{current_path} ]")
      next if true == fetch(:db_enabled_maintenance_mode)
      
      within current_path do
        if test :wp, "core", "is-installed"
          set :db_enabled_maintenance_mode, true
          
          invoke 'maintenance:enable'
        end
      end
    end
  end
  
  # Disable maintenance mode if it was enabled by check_maintenance_enable
  task :check_maintenance_disable do
    next unless true == fetch(:db_enabled_maintenance_mode)
    
    invoke 'maintenance:disable'
  end
end
