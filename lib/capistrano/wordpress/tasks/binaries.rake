namespace :binaries do
  desc "Check that all required binaries are installed"
  task :check do
    next if true == fetch(:checked_binaries)
    
    required_binaries = {
      local: [:php, :rsync, :wp],
      remote: {
        :all => [:wp],
        :app => [:rm, :rsync],
        :db => [:du, :mysqlshow]
      }
    }
  
    run_locally do
      required_binaries[:local].each do |binary|
        unless test :which, binary
          abort "The binary '#{binary}' is missing from the local system"
        end
      end
    end
  
    required_binaries[:remote].each do |role, binaries|
      on roles(role) do |server|
        binaries.each do |binary|
          unless test :which, binary
            error "The binary '#{binary}' is missing from #{server.user}@#{server.hostname}"
          end
        end
      end
    end
    
    set :checked_binaries, true
  end
end
