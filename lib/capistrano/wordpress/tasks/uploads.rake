namespace :uploads do
  desc "Push the uploads directory"
  task :push do
    directory = File.join("wp-content", "uploads")
    
    local_path = File.join(Dir.pwd, directory)
    remote_path = File.join(release_path, directory)
    
    unless File.directory? local_path
      error "No local uploads directory exists"
      
      next
    end
    
    on roles(:app) do |server|
      if current_path
        current_remote_path = File.join(current_path, directory)
        
        if capture("readlink -f #{current_path}").strip != release_path and test("[ -d #{current_remote_path} ]")
          debug "Cloning uploads directory from current release on #{server.user}@#{server.hostname}"
          
          execute :cp, "-R", current_remote_path, remote_path
        end
      end
      
      execute :mkdir, "-p", remote_path
      
      info "Pushing uploads directory to #{server.user}@#{server.hostname}"
      
      # Fix for rsync
      local_path = File.expand_path(local_path) + "/"
      
      run_locally do
        execute :rsync, "-lrtvzO", (server.port ? "-e 'ssh -p #{server.port}'" : nil), local_path, "#{server.user}@#{server.hostname}:#{remote_path}"
      end
    end
  end
  
  desc "Set permissions on the uploads directory"
  task :setperms do
    directory = File.join("wp-content", "uploads")
    
    remote_path = File.join(release_path, directory)
    
    on roles(:app) do |server|
      unless test("[ -d #{remote_path} ]")
        error "No uploads directory exists on #{server.user}@#{server.hostname}"
        
        next
      end
      
      info "Setting permissions for the uploads directory on #{server.user}@#{server.hostname}"
      
      execute :find, remote_path, "-type d", "-exec", :chmod, "755", "{}", "\\;"
      execute :find, remote_path, "-type f", "-exec", :chmod, "644", "{}", "\\;"
    end
  end
end
