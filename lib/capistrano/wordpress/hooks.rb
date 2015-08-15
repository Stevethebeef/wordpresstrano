# Check binaries before deploying
before "deploy", "binaries:check"

# Deploy resources before deploying
#before "deploy", "deploy:resources"

# Check directories before deploying resources
#before "deploy:resources", "deploy:check:directories"

# Push the local database before finishing a deployment
before "deploy:finishing", "db:push"

# Remove the existing WordPress core before downloading a new one
before "wp:core:download", "wp:core:remove"

# Check binaries before downloading the WordPress core
before "wp:core:download", "binaries:check"

# Check binaries before removing the WordPress core
before "wp:core:remove", "binaries:check"

# Download the WordPress core after symlinking the release
after "deploy:symlink:release", "wp:core:download"

# Link the new release into the website root
#after "deploy:finished", "webroot:symlink"

# Set permissions on the website root
#after "deploy:finished", "webroot:setperms"
