# Use the official MySQL image as base
FROM mysql:8.0

# Set environment variables (can be overridden at runtime)
ENV MYSQL_ROOT_PASSWORD=StrongRootPass123
ENV MYSQL_DATABASE=mydb
ENV MYSQL_USER=myuser
ENV MYSQL_PASSWORD=MyUserPass123

EXPOSE 3306
