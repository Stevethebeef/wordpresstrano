namespace :maintenance do
  desc "Enable maintenance mode on the WordPress site"
  task :enable do
    file = ".maintenance"
    
    on roles(:app) do |server|
      actual_current_path = capture("readlink -f #{current_path}").strip
      
      remote_path = File.join(actual_current_path, file)
      
      if test("[ -f #{remote_path} ]")
        info "Maintenance mode is already enabled on #{server.user}@#{server.hostname}"
        
        next
      end
      
      maintenance_info = fetch(:maintenance_info, {
        title: "Maintenance",
        header: "This site is currently undergoing maintenance.",
        body: "Please check back in a moment."
      })
      
      file_content = "<?php header('HTTP/1.1 503 Service Unavailable'); ?>\n"
      file_content << "<?php header('Content-Type: text/html'); ?>\n"
      file_content << "<!DOCTYPE html>\n"
      file_content << "<html>\n"
      file_content << "  <head>\n"
      file_content << "    <meta charset=\"utf-8\">\n"
      file_content << "    <meta name=\"viewport\" content=\"initial-scale=1.0\">\n"
      file_content << "    <title>#{maintenance_info[:title]}</title>\n" if maintenance_info.has_key? :title
      file_content << "  </head>\n"
      file_content << "  <body class=\"body\">\n"
      file_content << "    <h1>#{maintenance_info[:header]}</h1>\n" if maintenance_info.has_key? :header
      file_content << "    <h3>#{maintenance_info[:subheader]}</h3>\n" if maintenance_info.has_key? :subheader
      file_content << "    <p>#{maintenance_info[:body]}</p>\n" if maintenance_info.has_key? :body
      file_content << "  </body>\n"
      file_content << "</html>\n"
      file_content << "<?php exit; ?>\n"
      
      info "Enabling WordPress maintenance mode on #{server.user}@#{server.hostname}"
      
      upload! StringIO.new(file_content), remote_path
      
      execute :chmod, 644, remote_path
    end
  end
  
  desc "Disable maintenance mode on the WordPress site"
  task :disable do
    file = ".maintenance"
    
    on roles(:app) do |server|
      actual_current_path = capture("readlink -f #{current_path}").strip
      
      remote_path = File.join(actual_current_path, file)
      
      unless test("[ -f #{remote_path} ]")
        info "Maintenance mode is not enabled on #{server.user}@#{server.hostname}"
        
        next
      end
      
      info "Disabling WordPress maintenance mode on #{server.user}@#{server.hostname}"
      
      execute :rm, "-f", remote_path
    end
  end
end
