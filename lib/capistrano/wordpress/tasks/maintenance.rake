namespace :maintenance do
  desc "Enable maintenance mode on the WordPress site"
  task :enable do
    file = ".maintenance"
    
    template_path = File.join("config", "templates", "#{file}.erb")
    remote_path = File.join(release_path, file)
    
    on roles(:app) do |server|
      if test("[ -f #{remote_path} ]")
        info "Maintenance mode is already enabled on #{server.user}@#{server.hostname}"
        
        next
      end
      
      file_content = "<?php header('HTTP/1.1 503 Service Unavailable'); ?>\n"
      file_content << "<?php header('Content-Type: text/html'); ?>\n"
      
      if File.file? template_path
        file_content << ERB.new(File.read(template_path)).result(binding)
      else
        file_content << "<!DOCTYPE html>\n"
        file_content << "<html>\n"
        file_content << "  <head>\n"
        file_content << "    <meta charset=\"utf-8\">\n"
        file_content << "    <meta name=\"viewport\" content=\"initial-scale=1.0\">\n"
        file_content << "    <title>Maintenance</title>\n"
        file_content << "  </head>\n"
        file_content << "  <body class=\"body\">\n"
        file_content << "    <h1>This site is currently undergoing maintenance.</h1>\n"
        file_content << "    <h3>Please check back in a moment.</h3>\n"
        file_content << "  </body>\n"
        file_content << "</html>\n"
      end
      
      file_content << "<?php exit; ?>\n"
      
      next if file_content.nil? or file_content.empty?
      
      info "Enabling WordPress maintenance mode on #{server.user}@#{server.hostname}"
      
      upload! StringIO.new(file_content), remote_path
      
      execute :chmod, 644, remote_path
    end
  end
  
  desc "Disable maintenance mode on the WordPress site"
  task :disable do
    file = ".maintenance"
    
    remote_path = File.join(release_path, file)
    
    on roles(:app) do |server|
      unless test("[ -f #{remote_path} ]")
        info "Maintenance mode is not enabled on #{server.user}@#{server.hostname}"
        
        next
      end
      
      info "Disabling WordPress maintenance mode on #{server.user}@#{server.hostname}"
      
      execute :rm, "-f", remote_path
    end
  end
end
