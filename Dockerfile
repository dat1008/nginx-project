FROM nginx:1.27.1-alpine

# Create a non-root user for running nginx
RUN adduser -D -H -u 1000 -s /sbin/nologin www-data

# Copy the source files
COPY ./src /usr/share/nginx/html

# Set proper permissions
RUN chown -R www-data:www-data /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Use non-root user
USER www-data

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --quiet --tries=1 --spider http://localhost:80 || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
