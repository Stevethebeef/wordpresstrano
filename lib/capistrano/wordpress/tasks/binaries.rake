namespace :binaries do
  desc "Check that all required binaries are installed"
  task :check do
    next if fetch(:checked_binaries, false)
    
    required_binaries = {
      local: [:mysql, :mysqldump, :mysqlshow, :php, :rm, :rsync, :wp],
      remote: [:chmod, :du, :find, :grep, :ln, :mysql, :mysqldump, :mysqlshow, :readlink, :rm, :rsync, :wp]
    }
    
    required_binaries[:local].each do |binary|
      run_locally do
        unless test :which, binary
          abort "The binary '#{binary}' is missing from the local system"
        end
      end
    end
  
    required_binaries[:remote].each do |binary|
      on roles(:app) do |server|
        unless test :which, binary
          abort "The binary '#{binary}' is missing from #{server.user}@#{server.hostname}"
        end
      end
    end
    
    set :checked_binaries, true
  end
end
