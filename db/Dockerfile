# Base image
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y wget gnupg lsb-release libaio1 sudo curl && \
    rm -rf /var/lib/apt/lists/*

# Add MySQL repo and install MySQL server
RUN wget https://dev.mysql.com/get/mysql-apt-config_0.8.26-1_all.deb && \
    echo "mysql-apt-config mysql-apt-config/select-server select mysql-8.0" | debconf-set-selections && \
    dpkg -i mysql-apt-config_0.8.26-1_all.deb && \
    apt-get update && \
    apt-get install -y mysql-server && \
    rm -f mysql-apt-config_0.8.26-1_all.deb && \
    rm -rf /var/lib/apt/lists/*

# Initialize database
RUN mysqld --initialize-insecure --user=mysql

# Set working directory for init.sql
WORKDIR /docker-entrypoint-initdb.d

# Copy init.sql into container
COPY init.sql /docker-entrypoint-initdb.d/init.sql

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Expose MySQL port
EXPOSE 3306

# Entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["mysqld_safe"]
