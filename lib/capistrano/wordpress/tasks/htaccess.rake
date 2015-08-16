namespace :htaccess do
  desc "Pull down the .htaccess file"
  task :pull do
    file = ".htaccess"
    
    remote_file = File.join(release_path, file)
    
    next if 0 == roles(:app).count
    
    if 1 < roles(:app).count
      run_locally do
        info "Found #{roles(:app).count} application servers"
        
        roles(:app).each_with_index do |server, index|
          info "#{index + 1}) #{server.user}@#{server.hostname} (Port #{server.port or 22})"
        end
        
        set :htaccess_pull_server, ask("the number of the server to pull the #{file} file from", "1")
      end
    else
      set :htaccess_pull_server, "1"
    end
    
    htaccess_pull_server = fetch(:htaccess_pull_server).to_i
    htaccess_pull_server = roles(:app)[htaccess_pull_server - 1]
    
    on roles(:app) do |server|
      next unless server.matches? htaccess_pull_server
      
      unless test("[ -f #{remote_file} ]")
        error "There isn't a #{file} file on #{server.user}@#{server.hostname}"
        
        next
      end
      
      if File.file? file
        local_sha256sum = Digest::SHA256.hexdigest(File.read(file))
        remote_sha256sum = capture("sha256sum #{remote_file}").split(' ').first
        
        if local_sha256sum == remote_sha256sum
          info "No changes detected in #{file} file on #{server.user}@#{server.hostname}"
          
          next
        end
        
        unless fetch(:confirm_pull_htaccess)
          set :confirm_pull_htaccess, ask("confirmation for local #{file} file overwrite", "Y/n")
        end
        
        next unless [true, "y", "yes"].include? fetch(:confirm_pull_htaccess).downcase
      end
      
      info "Pulling #{file} file from #{server.user}@#{server.hostname}"
      
      download! remote_file, file
      
      break
    end
    
    set :htaccess_pull_server, nil
  end
  
  desc "Push up the .htaccess file"
  task :push do
    file = ".htaccess"
    
    local_path = File.join(Dir.pwd, file)
    remote_path = File.join(release_path, file)
    
    unless File.file? file
      run_locally do
        htaccess = "# BEGIN WordPress\n"
        htaccess << "<IfModule mod_rewrite.c>\n"
        htaccess << "RewriteEngine On\n"
        htaccess << "RewriteBase /\n"
        htaccess << "RewriteRule ^index\.php$ - [L]\n"
        htaccess << "RewriteCond %{REQUEST_FILENAME} !-f\n"
        htaccess << "RewriteCond %{REQUEST_FILENAME} !-d\n"
        htaccess << "RewriteRule . /index.php [L]\n"
        htaccess << "</IfModule>\n"
        htaccess << "# END WordPress\n"
        
        File.write(local_path, htaccess)
      end
    end
    
    on roles(:app) do |server|
      if test("[ -f #{remote_path} ]")
        local_sha256sum = Digest::SHA256.hexdigest(File.read(local_path))
        remote_sha256sum = capture("sha256sum #{remote_path}").split(' ').first
        
        if local_sha256sum == remote_sha256sum
          info "No changes detected in #{file} on #{server.user}@#{server.hostname}"
          
          next
        end
      end
      
      info "Pushing #{file} file to #{server.user}@#{server.hostname}"
      
      upload! local_path, remote_path
    end
  end
  
  desc "Set permissions on the .htaccess file"
  task :setperms do
    file = ".htaccess"
    
    remote_path = File.join(release_path, file)
    
    on roles(:app) do |server|
      unless test("[ -f #{remote_path} ]")
        info "No #{file} file found on #{server.user}@#{server.hostname}"
        
        next
      end
      
      info "Setting permissions for #{file} on #{server.user}@#{server.hostname}"
      
      execute :chmod, 644, remote_path
    end
  end
end
