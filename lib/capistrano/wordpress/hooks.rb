# Check binaries before performing tasks
before "deploy", "binaries:check"
before "wp:core:download", "binaries:check"
before "wp:core:remove", "binaries:check"

# Check directories before performing tasks
before "config:generate", "deploy:check:directories"
before "db:create", "deploy:check:directories"
before "db:push", "deploy:check:directories"
before "deploy:shared_configs", "deploy:check:directories"
before "htaccess:push", "deploy:check:directories"
before "robots:generate", "deploy:check:directories"
before "uploads:push", "deploy:check:directories"

# Deploy shared configuration files before deploying
before "deploy", "deploy:shared_configs"

# Load the local WordPress version so that when downloading the
# WordPress core on a remote server, the version matches the local installation.
before "deploy:updated", "wp:core:load_local_version"

# Remove the existing WordPress core before downloading a new one
before "wp:core:download", "wp:core:remove"

# Download the WordPress core files before finishing deploy:updated
before "deploy:updated", "wp:core:download"

# Set permissions on the resources after deploying them
after "config:generate", "config:setperms"
after "htaccess:push", "htaccess:setperms"
after "robots:generate", "robots:setperms"
after "uploads:push", "uploads:setperms"
after "deploy:finished", "webroot:setperms"

# Push the local resources after finishing deploy:updated
#after "deploy:reverted", "db:rollback"
after "deploy:updated", "db:push"
after "deploy:updated", "htaccess:push"
after "deploy:updated", "uploads:push"

# Link the release into the website root
after "deploy:finished", "webroot:symlink"
