# Check binaries before deploying
before "deploy", "binaries:check"

# Deploy resources before deploying
before "deploy", "deploy:resources"

# Check directories before deploying resources
before "deploy:resources", "deploy:check:directories"

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

# Download the WordPress core before symlinking the release
before "deploy:symlink:release", "wp:core:download"

# Push the local database before finishing a deployment
#before "deploy:symlink:release", "db:push"

# Link the new release into the website root
#after "deploy:finished", "webroot:symlink"

# Set permissions on the website root
#after "deploy:finished", "webroot:setperms"

# Set permissions on the wp-config.php file after generating
after "config:generate", "config:setperms"

# Set permissions on the robots.txt file after generating
after "robots:generate", "robots:setperms"
