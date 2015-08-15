namespace :robots do
  desc "Generate a robots.txt file"
  task :generate do
    file = "robots.txt"
    
    remote_path = File.join(shared_path, file)
    
    on roles(:app) do |server|
      info "Generating a #{file} file on #{server.user}@#{server.hostname}"
      
      if :production != fetch(:stage)
        debug "Disallowing all user agents in #{file} on #{server.user}@#{server.hostname}"
        
        upload! StringIO.new("User-agent: *\nDisallow: /"), remote_path
      else
        upload! StringIO.new, remote_path
      end
    end
  end
  
  desc "Set permissions on the robots.txt file"
  task :setperms do
    file = "robots.txt"
    
    remote_path = File.join(shared_path, file)
    
    on roles(:app) do |server|
      unless test("[ -f #{remote_path} ]")
        error "A #{file} file does not exist on #{server.user}@#{server.hostname}"
      end
      
      info "Setting permissions for #{file} on #{server.user}@#{server.hostname}"
      
      execute :chmod, 644, remote_path
    end
  end
end
