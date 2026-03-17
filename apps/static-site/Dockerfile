FROM nginx:1.25-alpine

# Remove default nginx page
RUN rm -rf /usr/share/nginx/html/*

# Copy static files
COPY index.html /usr/share/nginx/html/

# Custom nginx config to serve on port 8080
RUN echo 'server { listen 8080; location / { root /usr/share/nginx/html; index index.html; } }' \
    > /etc/nginx/conf.d/default.conf

EXPOSE 8080
