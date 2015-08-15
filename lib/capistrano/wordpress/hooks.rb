# Check for binaries before Deploy tasks
before "deploy:check", "binaries:check"

# Check for binaries before WordPress tasks
before "wp:core:download", "binaries:check"
before "wp:core:remove", "binaries:check"

# Remove existing WordPress core files before downloading a new ones
before "wp:core:download", "wp:core:remove"

# Deploy resources before deploying
#before "deploy", "deploy:resources"

# Download the WordPress core after downloading a release
#after "deploy:symlink:release", "wp:core:download"

# Link the current release into the website root after deploying
#after "deploy:finished", "webroot:setperms"
#after "deploy:finished", "webroot:symlink"
