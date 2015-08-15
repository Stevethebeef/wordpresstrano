namespace :wp do
  namespace :core do
    desc "Download the WordPress core files into the release"
    task :download do
      wp_version = fetch(:wp_version, ENV['version'])
      
      info "Downloading WordPress Core" + (wp_version.nil? "" : " (Version #{wp_version})")
      
      tmp_dir = File.join(fetch(:tmp_dir), SecureRandom.hex)
      
      execute :mkdir, "-p", tmp_dir
      
      within tmp_dir do
        execute :wp, "core", "download", (wp_version.nil? ? nil : "--version=#{wp_version}")
        
        wp_files.each do |glob|
          execute :cp, "-R", File.join(".", glob), release_path
        end
      end
      
      execute :rm, "-rf", tmp_dir
    end
  end
end
