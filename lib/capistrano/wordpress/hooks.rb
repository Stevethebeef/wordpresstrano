# Perform a safety check before running tasks
before "config:generate", "deploy:safety_check"
before "db:backup", "deploy:safety_check"
before "db:create", "deploy:safety_check"
before "db:list_backups", "deploy:safety_check"
before "db:push", "deploy:safety_check"
before "db:reset", "deploy:safety_check"
before "db:restore", "deploy:safety_check"
before "deploy", "deploy:safety_check"
before "deploy:all", "deploy:safety_check"
before "deploy:configs", "deploy:safety_check"
before "htaccess:push", "deploy:safety_check"
before "robots:generate", "deploy:safety_check"
before "uploads:push", "deploy:safety_check"
before "uploads:setperms", "deploy:safety_check"
before "wp:core:download", "deploy:safety_check"
before "wp:core:remove", "deploy:safety_check"

# Check if maintenance mode should be enabled before pushing the database
before "db:push", "maintenance:enable_if_previous_deployment"

# Create the MySQL database before pushing content to it
before "db:push", "db:create"

# Backup the database before pushing
before "db:push", "db:backup"

# Check if maintenance mode should be enabled before restoring the database
before "db:restore", "maintenance:enable_if_previous_deployment"

# Create the database before restoring
before "db:restore", "db:create"

# Check if there is a previous deployment before performing
# a partial deployment.
before "deploy", "deploy:check_for_previous_deployment"

# Set the timestamp to be used by the db:backup task
before "deploy:all", "db:match_backup_timestamp_with_release"
before "deploy:rollback", "db:match_backup_timestamp_with_release"

# Move the database backup from the release we rolled away from
# into the release's root before it's archived
before "deploy:cleanup_rollback", "db:cleanup_rollback_database"

# Remove the existing WordPress core before downloading a new one
before "wp:core:download", "wp:core:remove"

# Load the local WordPress version so that when downloading the
# WordPress core on a remote server, the version matches the local installation.
before "deploy:updated", "wp:core:load_local_version"

# Download the WordPress core files before finishing deploy:updated
before "deploy:updated", "wp:core:download"

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
after "db:push", "maintenance:disable_if_previous_deployment"

# Check if maintenance mode should be disabled after restoring the database
after "db:restore", "maintenance:disable_if_previous_deployment"

# Rollback the database after rolling back the files
after "deploy:reverted", "db:rollback"

# Clone resources from the previous release (if they exist)
after "deploy:updated", "htaccess:clone_from_previous_release"
after "deploy:updated", "uploads:clone_from_previous_release"
