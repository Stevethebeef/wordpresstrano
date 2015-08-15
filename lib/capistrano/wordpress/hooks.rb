# Check binaries before deploying
before "deploy", "binaries:check"

# Deploy shared configuration files before deploying
before "deploy", "deploy:shared_configs"

# Check directories before deploying shared configurations
before "deploy:shared_configs", "deploy:check:directories"

# Remove the existing WordPress core before downloading a new one
before "wp:core:download", "wp:core:remove"

# Check binaries before downloading the WordPress core
before "wp:core:download", "binaries:check"

# Check binaries before removing the WordPress core
before "wp:core:remove", "binaries:check"

# Check directories before generating a wp-config.php file
before "config:generate", "deploy:check:directories"

# Check directories before generating a robots.txt file
before "robots:generate", "deploy:check:directories"

# Download the WordPress core before calling updated on the release
before "deploy:updated", "wp:core:download"

# Check directories before pushing a htaccess file
before "htaccess:push", "deploy:check:directories"

# Check directories before pushing a uploads directory
before "uploads:push", "deploy:check:directories"

# Push the local .htaccess file before publishing the deployment
before "deploy:publishing", "htaccess:push"

# Push the local uploads directory before publishing the deployment
before "deploy:publishing", "uploads:push"

# Push the local database before publishing the deployment
#before "deploy:publishing", "db:push"

# Link the new release into the website root
#after "deploy:finished", "webroot:symlink"

# Set permissions on the website root
#after "deploy:finished", "webroot:setperms"

# Set permissions on the wp-config.php file after generating
after "config:generate", "config:setperms"

# Set permissions on the robots.txt file after generating
after "robots:generate", "robots:setperms"

# Set permissions on the .htaccess file after pushing
after "htaccess:push", "htaccess:setperms"

# Set permissions on the uploads directory after pushing
after "uploads:push", "uploads:setperms"
