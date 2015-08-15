require "net/http"
require "securerandom"
require "time"

# Load all helpers and capistrano tasks
["wordpress/helpers/**/*.rb", "wordpress/tasks/**/*.rake", "wordpress/hooks.rb"].each do |glob|
  Dir.glob(File.expand_path(File.join('..', glob), __FILE__)).each do |file_path|
    load file_path
  end
end

# Tell capistrano about files we want linked into releases
set :linked_files, fetch(:linked_files, []).push("robots.txt", "wp-config.php")
