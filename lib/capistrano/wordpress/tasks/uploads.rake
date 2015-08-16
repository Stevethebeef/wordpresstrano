namespace :uploads do
  desc "Pull down the uploads directory"
  task :pull do
    directory = File.join("wp-content", "uploads")
    
    local_path = File.join(Dir.pwd, directory)
    remote_path = File.join(release_path, directory)
    
    next if 0 == roles(:app).count
    
    if 1 < roles(:app).count
      run_locally do
        info "Found #{roles(:app).count} application servers"
        
        roles(:app).each_with_index do |server, index|
          info "#{index + 1}) #{server.user}@#{server.hostname} (Port #{server.port or 22})"
        end
        
        set :uploads_pull_server, ask("the number of the server to pull the #{directory} directory from", "1")
      end
    else
      set :uploads_pull_server, "1"
    end
    
    uploads_pull_server = fetch(:uploads_pull_server).to_i
    
    if 1 > uploads_pull_server or roles(:app).count < uploads_pull_server
      run_locally do
        error "Unable to locate a server with an id '#{uploads_pull_server}'"
      end
      
      next
    end
    
    uploads_pull_server = roles(:app)[uploads_pull_server - 1]
    
    on roles(:app) do |server|
      next unless server.matches? uploads_pull_server
      
      unless test("[ -d #{remote_path} ]")
        error "There isn't a #{directory} directory on #{server.user}@#{server.hostname}"
        
        next
      end
      
      run_locally do
        execute :mkdir, "-p", local_path
      end
      
      info "Pulling #{directory} directory from #{server.user}@#{server.hostname}"
      
      # Fix for rsync
      remote_path += "/"
      
      run_locally do
        execute :rsync, "-lrtvzO", (server.port ? "-e 'ssh -p #{server.port}'" : nil), "#{server.user}@#{server.hostname}:#{remote_path}", local_path
      end
    end
    
    set :uploads_pull_server, nil
  end
  
  desc "Push up the uploads directory"
  task :push do
    directory = File.join("wp-content", "uploads")
    
    local_path = File.join(Dir.pwd, directory)
    remote_path = File.join(release_path, directory)
    
    unless File.directory? local_path
      error "No local uploads directory exists"
      
      next
    end
    
    on roles(:app) do |server|
      if test("[ -d #{current_path} ]") and (ENV["clone_uploads"].nil? or ENV["clone_uploads"].empty? or [true, "true", "yes", "y"].include? ENV["clone_uploads"].downcase)
        actual_current_path = capture("readlink -f #{current_path}").strip
        actual_release_path = capture("readlink -f #{release_path}").strip
        
        previous_remote_path = File.join(actual_current_path, directory)
        
        if actual_current_path != actual_release_path and test("[ -d #{previous_remote_path} ]")
          debug "Cloning uploads directory from current release on #{server.user}@#{server.hostname}"
          
          execute :cp, "-R", "--preserve=timestamps", previous_remote_path, remote_path
        end
      end
      
      execute :mkdir, "-p", remote_path
      
      info "Pushing #{directory} directory to #{server.user}@#{server.hostname}"
      
      # Fix for rsync
      local_path += "/"
      
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
      
      execute :find, remote_path, "-type d", "-exec", :chmod, 755, "{}", "\\;"
      execute :find, remote_path, "-type f", "-exec", :chmod, 644, "{}", "\\;"
    end
  end
end
