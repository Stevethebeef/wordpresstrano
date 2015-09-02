namespace :htaccess do
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
  
  task :clone_from_previous_release do
    file = ".htaccess"
    
    remote_path = File.join(release_path, file)
    
    on roles(:app) do |server|
      if test("[ -d #{current_path} ]")
        actual_current_path = capture("readlink -f #{current_path}").strip
        actual_release_path = capture("readlink -f #{release_path}").strip
        
        previous_remote_path = File.join(actual_current_path, file)
        
        if actual_current_path != actual_release_path and test("[ -d #{previous_remote_path} ]")
          debug "Cloning #{file} file from current release on #{server.user}@#{server.hostname}"
          
          execute :cp, "--preserve=timestamps", previous_remote_path, remote_path
        end
      end
    end
  end
end
