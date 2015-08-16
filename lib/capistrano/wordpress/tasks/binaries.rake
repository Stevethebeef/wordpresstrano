namespace :binaries do
  desc "Check that all required binaries are installed"
  task :check do
    next if true == fetch(:checked_binaries)
    
    required_binaries = {
      local: [:php, :rm, :rsync, :wp],
      remote: {
        :all => [:chmod, :find, :rm, :wp],
        :app => [:ln, :readlink, :rsync],
        :db => [:du, :grep, :mysqlshow]
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
            abort "The binary '#{binary}' is missing from #{server.user}@#{server.hostname}"
          end
        end
      end
    end
    
    set :checked_binaries, true
  end
end
