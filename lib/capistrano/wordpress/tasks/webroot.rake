namespace :webroot do
  desc "Symlink the current release into the website root"
  task :symlink do
    remote_path = fetch(:website_root)
    
    next unless remote_path
    
    on roles(:app) do |server|
      info "Symlinking the current release into the website root on #{server.user}@#{server.hostname}"
      
      execute :rm, "-rf", remote_path, "&&", :ln, "-nfs", release_path, remote_path
    end
  end
  
  desc "Set permissions on the uploads directory"
  task :setperms do
    remote_path = fetch(:website_root)
    
    next unless remote_path
    
    on roles(:app) do |server|
      unless test("[ -d #{remote_path} ]")
        error "No website root directory exists on #{server.user}@#{server.hostname}"
        
        next
      end
      
      info "Setting permissions for the website root directory on #{server.user}@#{server.hostname}"
      
      execute :find, remote_path, "-type d", "-exec", :chmod, 755, "{}", "\\;"
      execute :find, remote_path, "-type f", "-exec", :chmod, 644, "{}", "\\;"
    end
  end
end
