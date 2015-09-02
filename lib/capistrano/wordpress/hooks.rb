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

# Check if maintenance mode should be enabled before pushing the database
before "db:push", "db:check_maintenance_enable"

# Create the MySQL database before pushing content to it
before "db:push", "db:create"

# Backup the database before pushing
before "db:push", "db:backup"

# Check if maintenance mode should be enabled before restoring the database
before "db:restore", "db:check_maintenance_enable"

# Create the database before restoring
before "db:restore", "db:create"


# Move the database backup from the release we rolled away from
# into the release's root before it's archived
before "deploy:cleanup_rollback", "db:cleanup_rollback_database"

# Load the local WordPress version so that when downloading the
# WordPress core on a remote server, the version matches the local installation.
before "deploy:updated", "wp:core:load_local_version"

# Remove the existing WordPress core before downloading a new one
before "wp:core:download", "wp:core:remove"

# Download the WordPress core files before finishing deploy:updated
before "deploy:updated", "wp:core:download"

# Check if we can deploy without pushing htaccess/uploads/database
before "deploy", "deploy:check_for_previous_deployment"

# Link the release into the website root
after "deploy:finished", "webroot:symlink"

# Touch the release directory after deploying
# This is required as after the first deployment, we enable
# maintenance mode for every subsequent deployment. This causes
# the previous release directory to have a newer timestamp than
# the new release directory which leads to issues with the rollback
# feature as the releases directory is sorted by modification time
# when capistrano looks for the release to rollback to.
after "deploy:finishing", "deploy:touch_release"

# Set permissions on the resources after deploying them
after "config:generate", "config:setperms"
after "htaccess:push", "htaccess:setperms"
after "robots:generate", "robots:setperms"
after "uploads:push", "uploads:setperms"
after "deploy:finished", "webroot:setperms"

# Check if maintenance mode should be disabled after pushing the database
after "db:push", "db:check_maintenance_disable"

# Check if maintenance mode should be disabled after restoring the database
after "db:restore", "db:check_maintenance_disable"

# Rollback the database after rolling back the files
after "deploy:reverted", "db:rollback"

# Clone resources from the previous release (if they exist)
after "deploy:updated", "htaccess:clone_from_previous_release"
after "deploy:updated", "uploads:clone_from_previous_release"
