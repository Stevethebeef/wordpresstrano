# Load all helpers and capistrano tasks
["wordpress/helpers/**/*.rb", "wordpress/tasks/**/*.rake"].each do |glob|
  Dir.glob(File.expand_path(File.join('..', glob), __FILE__)).each do |file_path|
    load file_path
  end
end
