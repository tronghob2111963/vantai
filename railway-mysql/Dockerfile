# MySQL Dockerfile cho Railway
FROM mysql:8.0.43-debian

# Environment variables sẽ được Railway tự động inject
# Hoặc set trong Railway Dashboard → Variables
ENV MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-root}
ENV MYSQL_DATABASE=${MYSQL_DATABASE:-ptcmss_db}
ENV MYSQL_USER=${MYSQL_USER:-ptcmss_user}
ENV MYSQL_PASSWORD=${MYSQL_PASSWORD:-ptcmss_password}

# Expose MySQL port
EXPOSE 3306

# MySQL sẽ tự động chạy khi container start
CMD ["mysqld"]

