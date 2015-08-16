# Check binaries before performing tasks
before "db:backup", "binaries:check"
before "db:create", "binaries:check"
before "db:list_backups", "binaries:check"
before "db:pull", "binaries:check"
before "db:push", "binaries:check"
before "db:reset", "binaries:check"
before "db:restore", "binaries:check"
before "deploy", "binaries:check"
before "htaccess:pull", "binaries:check"
before "htaccess:push", "binaries:check"
before "uploads:pull", "binaries:check"
before "uploads:push", "binaries:check"
before "uploads:setperms", "binaries:check"
before "wp:core:download", "binaries:check"
before "wp:core:remove", "binaries:check"

# Check directories before performing tasks
before "config:generate", "deploy:check:directories"
before "db:backup", "deploy:check:directories"
before "db:create", "deploy:check:directories"
before "db:list_backups", "deploy:check:directories"
before "db:pull", "deploy:check:directories"
before "db:push", "deploy:check:directories"
before "db:reset", "deploy:check:directories"
before "db:restore", "deploy:check:directories"
before "deploy:shared_configs", "deploy:check:directories"
before "htaccess:pull", "deploy:check:directories"
before "htaccess:push", "deploy:check:directories"
before "robots:generate", "deploy:check:directories"
before "uploads:pull", "deploy:check:directories"
before "uploads:push", "deploy:check:directories"

# Backup the database before deleting
before "db:drop", "db:backup"

# Check if maintenance mode should be enabled before pushing the database
before "db:push", "db:check_maintenance_enable"

# Create the MySQL database before pushing content to it
before "db:push", "db:create"

# Backup the database before pushing
before "db:push", "db:backup"

# Backup the database before resetting
before "db:reset", "db:backup"

# Deploy shared configuration files before deploying
before "deploy", "deploy:shared_configs"

# Load the local WordPress version so that when downloading the
# WordPress core on a remote server, the version matches the local installation.
before "deploy:updated", "wp:core:load_local_version"

# Remove the existing WordPress core before downloading a new one
before "wp:core:download", "wp:core:remove"

# Download the WordPress core files before finishing deploy:updated
before "deploy:updated", "wp:core:download"

# Link the release into the website root
after "deploy:finished", "webroot:symlink"

# Set permissions on the resources after deploying them
after "config:generate", "config:setperms"
after "htaccess:push", "htaccess:setperms"
after "robots:generate", "robots:setperms"
after "uploads:push", "uploads:setperms"
after "deploy:finished", "webroot:setperms"

# Check if maintenance mode should be disabled after pushing the database
after "db:push", "db:check_maintenance_disable"

# Push the local resources after finishing deploy:updated
#after "deploy:reverted", "db:rollback"
after "deploy:updated", "htaccess:push"
after "deploy:updated", "uploads:push"
after "deploy:updated", "db:push" # We want this to happen last so leave it here :)
