namespace :htaccess do
  desc "Push up the .htaccess file"
  task :push do
    file = ".htaccess"
    
    remote_file = File.join(release_path, file)
    
    on roles(:app) do |server|
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
          
          File.write(file, htaccess)
        end
      end
      
      if test("[ -f #{remote_file} ]")
        local_sha256sum = Digest::SHA256.hexdigest(File.read(file))
        remote_sha256sum = capture("sha256sum #{remote_file}").split(' ').first
        
        if local_sha256sum == remote_sha256sum
          info "No changes detected in #{file} on #{server.user}@#{server.hostname}"
          
          next
        end
        
        unless fetch(:confirm_push_htaccess)
          set :confirm_push_htaccess, ask("confirmation for remote #{file} file overwrite", "Y/n")
        end
        
        next unless [true, "y", "yes"].include? fetch(:confirm_push_htaccess).downcase
      end
      
      info "Pushing #{file} file to #{server.user}@#{server.hostname}"
      
      upload! file, remote_file
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
