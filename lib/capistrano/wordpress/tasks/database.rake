namespace :db do
  desc "Push up the WordPress database"
  task :push do
    file = "#{SecureRandom.hex(8)}.sql"
    
    local_path = File.join(Dir.pwd, file)
    remote_path = File.join(fetch(:tmp_dir), file)
    
    on roles(:app) do |server|
      info "Pushing WordPress database to #{server.user}@#{server.hostname}"
      
      run_locally do
        execute :wp, :db, :export, local_path
      end
      
      upload! local_path, remote_path
      
      run_locally do
        execute :rm, "-f", local_path
      end
      
      within release_path do
        execute :wp, :db, :import, remote_path
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
    
    on roles(:app) do |server|
      within release_path do
        if test("[ \"#{database_name.gsub!('$', '\$')}\" == $(mysqlshow --user=\"#{database_username.gsub!('$', '\$')}\" --password=\"#{database_password.gsub!('$', '\$')}\" #{database_name.gsub!('$', '\$')} | grep -v Wildcard | grep -o #{database_name.gsub!('$', '\$')}) ]")
          error "The MySQL database already exists on #{server.user}@#{server.hostname}"
          
          next
        end
        
        info "Creating MySQL database on #{server.user}@#{server.hostname}"
        
        execute :wp, :db, :create
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
    
    on roles(:app) do |server|
      within release_path do
        unless test("[ \"#{database_name.gsub!('$', '\$')}\" == $(mysqlshow --user=\"#{database_username.gsub!('$', '\$')}\" --password=\"#{database_password.gsub!('$', '\$')}\" #{database_name.gsub!('$', '\$')} | grep -v Wildcard | grep -o #{database_name.gsub!('$', '\$')}) ]")
          error "The MySQL database does not exist on #{server.user}@#{server.hostname}"
          
          next
        end
        
        info "Deleting MySQL database on #{server.user}@#{server.hostname}"
        
        execute :wp, :db, :drop, "--yes"
      end
    end
  end
  
  desc "Reset the MySQL database"
  task :reset do
    on roles(:app) do |server|
      within release_path do
        unless test :wp, :core, "is-installed"
          error "The WordPress database does not appear to be installed on #{server.user}@#{server.hostname}"
          
          next
        end
        
        info "Resetting the WordPress database on #{server.user}@#{server.hostname}"
        
        execute :wp, :db, :reset, "--yes"
      end
    end
  end
  
  desc "Create a backup of the WordPress database"
  task :backup do
    backups_directory = File.join(fetch(:deploy_to), "backups", "database")
    
    on roles(:app) do |server|
      next unless test("[ -d #{current_path} ]")
      
      timestamp = fetch(:db_backup_timestamp, Time.now.strftime("%Y%m%d%H%M%S"))
      
      file = "#{timestamp}.sql"
      
      remote_path = File.join(backups_directory, file)
      
      info "Backing up WordPress database on #{server.user}@#{server.hostname}"
      
      execute :mkdir, "-p", backups_directory
      
      if test("[ -f #{remote_path} ]")
        execute :rm, "-f", remote_path
      end
      
      within release_path do
        execute :wp, :db, :export, remote_path
      end
    end
  end
  
  desc "Restore a backup of the WordPress database"
  task :restore do
    backups_directory = File.join(fetch(:deploy_to), "backups", "database")
    
    backup_id = fetch(:db_restore_timestamp, ENV['id'])
    
    unless backup_id
      run_locally do
        error "You must provide the ID of the backup to restore!"
      end
      
      next
    end
    
    on roles(:app) do |server|
      file = "#{backup_id}.sql"
    
      remote_path = File.join(backups_directory, file)
      
      unless test("[ -f #{remote_path} ]")
        info "No database backup found for the id '#{backup_id}' on #{server.user}@#{server.hostname}"
        
        next
      end
      
      info "Rolling back the database to '#{backup_id}' on #{server.user}@#{server.hostname}"
      
      within release_path do
        execute :wp, :db, :import, remote_path
      end
    end
  end
  
  desc "List all WordPress database backups"
  task :list_backups do
    on roles(:app) do |server|
      backups_directory = File.join(fetch(:deploy_to), "backups", "database")
      
      unless test("[ -d #{backups_directory} ]")
        error "No database backups found on #{server.user}@#{server.hostname}"
        
        next
      end
      
      backup_paths = capture("find #{backups_directory} -name '*.sql' -maxdepth 1")
      
      if backup_paths.nil? or backup_paths.empty?
        error "No database backups found on #{server.user}@#{server.hostname}"
        
        next
      end
      
      info "Found #{backup_paths.lines.count} database backup(s) on #{server.user}@#{server.hostname}"
      
      backup_paths.each_line do |backup_path|
        backup_path = backup_path.strip
        
        backup_basename = File.basename(backup_path).gsub(".sql", "").strip
        
        backup_time = Time.parse(backup_basename)
        backup_time = backup_time.strftime("%A #{backup_time.day.ordinalize} %B %Y at %H:%M:%S")
        
        backup_size = capture("du -h #{backup_path} | awk '{ print \$1 }'")
        
        info "#{backup_time} - #{backup_size} (ID: #{backup_basename})"
      end
    end
  end
  
  # Rollback the WordPress database
  # This is only useful when called during a deploy:rollback task
  task :rollback do
    actual_current_path = nil
    actual_release_path = nil
    
    on roles(:app) do |server|
      actual_current_path = capture("readlink -f #{current_path}").strip
      actual_release_path = capture("readlink -f #{release_path}").strip
    end
    
    if actual_current_path == actual_release_path
      run_locally do
        error "This task is only useful when called during a deploy:rollback task!"
      end
      
      next
    end
    
    set :db_restore_timestamp, File.basename(actual_release_path)
    
    invoke 'db:backup'
    invoke 'db:restore'
  end
  
  # Move the database backup from the release we rolled away from
  # into the release's root before it's archived
  task :cleanup_rollback_database do
    db_backup_timestamp = fetch(:db_backup_timestamp)
    
    next unless db_backup_timestamp
    
    file = "database.sql"
    
    backups_directory = File.join(fetch(:deploy_to), "backups", "database")
    
    source_path = File.join(backups_directory, file)
    destination_path = File.join(releases_path, db_backup_timestamp, file)
    
    on roles(:app) do |server|
      unless test("[ -f #{source_path} ]")
        error "The database backup (#{db_backup_timestamp}) does not exist on #{server.user}@#{server.hostname}"
        
        next
      end
      
      info "Moving database backup #{db_backup_timestamp} into release on #{server.user}@#{server.hostname}"
      
      execute :mv, source_path, destination_path
    end
  end
  
  # Set the timestamp for the backup task to match
  # the timestamp of the current release.
  task :match_backup_timestamp_with_release do
    on roles(:app) do
      if test("[ -d #{current_path} ]")
        set :db_backup_timestamp, File.basename(capture("readlink -f #{current_path}").strip)
      end
    end
  end
end
