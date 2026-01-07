# Use the official Nginx image as a lightweight web server
FROM nginx:alpine

# Copy static website files into Nginx's default web root
COPY index.html /usr/share/nginx/html/
COPY styles.css /usr/share/nginx/html/
COPY script.js /usr/share/nginx/html/

# Expose port 80 for HTTP traffic
EXPOSE 80
