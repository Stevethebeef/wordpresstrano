namespace :robots do
  desc "Generate a robots.txt file"
  task :generate do
    on roles(:app) do |server|
      info "Generating a robots.txt file on #{server.user}@#{server.hostname}"
      
      remote_path = File.join(shared_path, "robots.txt")
      
      if :production != fetch(:stage)
        debug "Disallowing all user agents in robots.txt on #{server.user}@#{server.hostname}"
        
        upload! StringIO.new("User-agent: *\nDisallow: /"), remote_path
      else
        upload! StringIO.new, remote_path
      end
    end
  end
  
  desc "Set permissions on the robots.txt file"
  task :setperms do
    on roles(:app) do |server|
      remote_path = File.join(shared_path, "robots.txt")
      
      unless test("[ -f #{remote_path} ]")
        error "The robots.txt file does not exist on #{server.user}@#{server.hostname}"
      end
      
      info "Setting permissions for robots.txt on #{server.user}@#{server.hostname}"
      
      execute :chmod, 644, remote_path
    end
  end
end
