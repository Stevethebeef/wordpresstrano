namespace :wp do
  namespace :core do
    desc "Download the WordPress core files into the release"
    task :download do
      on roles(:app) do |server|
        version = fetch(:wp_version, ENV["version"])
        
        info "Downloading WordPress Core" + (version ? " (Version #{version})" : "")
        
        tmp_dir = File.join(fetch(:tmp_dir), SecureRandom.hex(8))
        
        execute :mkdir, "-p", tmp_dir
        
        invoke 'wp:core:remove'
        
        within tmp_dir do
          execute :wp, "core", "download", (version ? "--version=#{version}" : "")
          
          excludes = [".", "license.txt", "readme.html", "wp-config-sample.php", "wp-content"]
          excludes = excludes.map { |e| "! -name '#{e}' " }.join(" ").squeeze(" ").strip
          
          paths = capture :find, ".", "-maxdepth 1", excludes
          paths = paths.split("\n")
          paths.each do |path|
            execute :cp, "-R", path, release_path
          end
        end
        
        execute :rm, "-rf", tmp_dir
      end
    end
    
    desc "Remove the WordPress core files from the release"
    task :remove do
      on roles(:app) do
        within release_path do
          paths = []
          
          excludes = [".", "wp-config.php"]
          excludes = excludes.map { |e| "! -name '#{e}' " }.join(" ").squeeze(" ").strip
          
          ["index.php", "wp-*", "xmlrpc.php"].each do |glob|
            find_output = capture :find, ".", "-maxdepth 1", "-name '#{glob}'", excludes
            
            paths.concat(find_output.split("\n"))
          end
          
          next if 1 > paths.length
          
          info "Removing #{paths.length} WordPress core file(s)"
          
          paths.each do |path|
            execute :rm, "-rf", path
          end
        end
      end
    end
  end
  
  desc "Execute a WordPress CLI command"
  task :exec do
    set :wp_exec_command, ask("The WordPress CLI command to execute", "help")
    
    unless fetch(:wp_exec_command)
      abort "You didn't enter a command to execute"
    end
    
    on roles(:all) do |server|
      next if ENV["role"] and !server.roles.map { |role| role.to_s }.include? ENV["role"]
      
      within release_path do
        puts capture :wp, fetch(:wp_exec_command)
      end
    end
    
    set :wp_exec_command, nil
  end
end
