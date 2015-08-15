namespace :config do
  desc "Generate a wp-config.php file"
  task :generate do
    file = "wp-config.php"
    
    remote_path = File.join(shared_path, file)
    
    template_path = File.join("config", "templates", "#{file}.erb")
    template_content = File.read(template_path)
    
    run_locally do
      database_config = fetch(:local_database_config)
      
      unless database_config.has_keys? :hostname, :username, :database, :password
        abort "The local database configuration is invalid"
      end
      
      database_hostname = database_config[:hostname]
      database_username = database_config[:username]
      database_name = database_config[:database]
      database_password = database_config[:password]
      
      secret_keys = Net::HTTP.get URI("https://api.wordpress.org/secret-key/1.1/salt")
      
      if secret_keys.nil? or secret_keys.empty?
        abort "Unable to fetch secret keys using the WordPress API"
      end
      
      configuration = ERB.new(template_content).result(binding)
      
      if test("[ -f #{file} ]")
        execute :rm, "-f", file
      end
      
      info "Writing local #{file} file"
      
      File.write(file, configuration)
    end
    
    database_config = fetch(:database_config)
    
    unless database_config.has_keys? :hostname, :username, :database, :password
      abort "The #{fetch(:stage)} database configuration is invalid"
    end
    
    database_hostname = database_config[:hostname]
    database_username = database_config[:username]
    database_name = database_config[:database]
    database_password = database_config[:password]
    
    secret_keys = Net::HTTP.get URI("https://api.wordpress.org/secret-key/1.1/salt")
    
    if secret_keys.nil? or secret_keys.empty?
      abort "Unable to fetch secret keys using the WordPress API"
    end
    
    configuration = ERB.new(template_content).result(binding)
    
    on roles(:app) do |server|
      if test("[ -f #{remote_path} ]")
        execute :rm, "-f", remote_path
      end
      
      upload! StringIO.new(configuration), remote_path
    end
  end
  
  desc "Set permissions on the wp-config.php file"
  task :setperms do
    on roles(:app) do |server|
      file = "wp-config.php"
      
      remote_path = File.join(shared_path, file)
      
      unless test("[ -f #{remote_path} ]")
        error "A #{file} file does not exist on #{server.user}@#{server.hostname}"
      end
      
      info "Setting permissions for #{file} on #{server.user}@#{server.hostname}"
      
      execute :chmod, 644, remote_path
    end
  end
end
