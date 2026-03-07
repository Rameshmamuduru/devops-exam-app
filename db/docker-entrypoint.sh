#!/bin/bash
set -e

# Start MySQL in background
mysqld_safe &

# Wait for MySQL to fully start
sleep 5

# Execute init.sql if exists
if [ -f /docker-entrypoint-initdb.d/init.sql ]; then
    echo "Running init.sql..."
    mysql < /docker-entrypoint-initdb.d/init.sql
fi

# Optional: create default admin user if not in init.sql
mysql -e "CREATE USER IF NOT EXISTS 'admin'@'%' IDENTIFIED BY 'StrongPassword123';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;"
mysql -e "FLUSH PRIVILEGES;"

# Keep container running
wait
