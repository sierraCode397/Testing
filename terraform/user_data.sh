#!/bin/bash
# Update and install nginx + a simple static page
apt-get update
apt-get install -y nginx

# Create a minimal index.html
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head><title>Welcome to my EC2!</title></head>
<body style="font-family:Arial,Helvetica,sans-serif;text-align:center;margin-top:50px;">
<h1>Hello from Terraform‑deployed EC2!</h1>
<p>This page is served by Nginx on a t2.micro instance.</p>
</body>
</html>
EOF

# Ensure nginx starts on boot
systemctl enable nginx
systemctl start nginx
