# Multi-stage build for Equicrew Frontend
ARG BUILD_FROM

# Stage 1: Build the frontend
FROM --platform=linux/amd64 node:20-alpine AS builder

WORKDIR /build

# Install build dependencies
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    git \
    bash

# Copy package files, yarn config and patches
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn/patches .yarn/patches
COPY .yarn/releases .yarn/releases
RUN corepack enable && \
    yarn install --immutable

# Copy source code
COPY . .

# Download all translations and build frontend
RUN yarn gulp download-translations && yarn build

# Stage 2: Create the runtime container
ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install nginx for serving the frontend
RUN apk add --no-cache nginx

# Copy built frontend from builder stage
COPY --from=builder /build/hass_frontend /usr/share/nginx/html

# Configure nginx with API proxy to Home Assistant Core
RUN mkdir -p /etc/nginx/http.d && \
    echo 'server {' > /etc/nginx/http.d/default.conf && \
    echo '    listen 8099;' >> /etc/nginx/http.d/default.conf && \
    echo '    root /usr/share/nginx/html;' >> /etc/nginx/http.d/default.conf && \
    echo '    index index.html;' >> /etc/nginx/http.d/default.conf && \
    echo '' >> /etc/nginx/http.d/default.conf && \
    echo '    # Increase buffer sizes for large URIs and headers' >> /etc/nginx/http.d/default.conf && \
    echo '    large_client_header_buffers 4 64k;' >> /etc/nginx/http.d/default.conf && \
    echo '    client_header_buffer_size 64k;' >> /etc/nginx/http.d/default.conf && \
    echo '    proxy_buffer_size 128k;' >> /etc/nginx/http.d/default.conf && \
    echo '    proxy_buffers 4 256k;' >> /etc/nginx/http.d/default.conf && \
    echo '    proxy_busy_buffers_size 256k;' >> /etc/nginx/http.d/default.conf && \
    echo '' >> /etc/nginx/http.d/default.conf && \
    echo '    # Proxy API requests to Home Assistant Core' >> /etc/nginx/http.d/default.conf && \
    echo '    location /api/ {' >> /etc/nginx/http.d/default.conf && \
    echo '        proxy_pass http://homeassistant:8123/api/;' >> /etc/nginx/http.d/default.conf && \
    echo '        proxy_http_version 1.1;' >> /etc/nginx/http.d/default.conf && \
    echo '        proxy_set_header Host $host;' >> /etc/nginx/http.d/default.conf && \
    echo '        proxy_set_header X-Real-IP $remote_addr;' >> /etc/nginx/http.d/default.conf && \
    echo '        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;' >> /etc/nginx/http.d/default.conf && \
    echo '        proxy_set_header Upgrade $http_upgrade;' >> /etc/nginx/http.d/default.conf && \
    echo '        proxy_set_header Connection "upgrade";' >> /etc/nginx/http.d/default.conf && \
    echo '        proxy_read_timeout 86400;' >> /etc/nginx/http.d/default.conf && \
    echo '    }' >> /etc/nginx/http.d/default.conf && \
    echo '' >> /etc/nginx/http.d/default.conf && \
    echo '    # Proxy Auth API endpoints to Home Assistant Core (NOT /auth/authorize which serves HTML)' >> /etc/nginx/http.d/default.conf && \
    echo '    location /auth/token {' >> /etc/nginx/http.d/default.conf && \
    echo '        proxy_pass http://homeassistant:8123/auth/token;' >> /etc/nginx/http.d/default.conf && \
    echo '        proxy_http_version 1.1;' >> /etc/nginx/http.d/default.conf && \
    echo '        proxy_set_header Host $host;' >> /etc/nginx/http.d/default.conf && \
    echo '        proxy_set_header X-Real-IP $remote_addr;' >> /etc/nginx/http.d/default.conf && \
    echo '        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;' >> /etc/nginx/http.d/default.conf && \
    echo '    }' >> /etc/nginx/http.d/default.conf && \
    echo '' >> /etc/nginx/http.d/default.conf && \
    echo '    location /auth/providers {' >> /etc/nginx/http.d/default.conf && \
    echo '        proxy_pass http://homeassistant:8123/auth/providers;' >> /etc/nginx/http.d/default.conf && \
    echo '        proxy_http_version 1.1;' >> /etc/nginx/http.d/default.conf && \
    echo '        proxy_set_header Host $host;' >> /etc/nginx/http.d/default.conf && \
    echo '        proxy_set_header X-Real-IP $remote_addr;' >> /etc/nginx/http.d/default.conf && \
    echo '        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;' >> /etc/nginx/http.d/default.conf && \
    echo '    }' >> /etc/nginx/http.d/default.conf && \
    echo '' >> /etc/nginx/http.d/default.conf && \
    echo '    location /auth/login_flow {' >> /etc/nginx/http.d/default.conf && \
    echo '        proxy_pass http://homeassistant:8123/auth/login_flow;' >> /etc/nginx/http.d/default.conf && \
    echo '        proxy_http_version 1.1;' >> /etc/nginx/http.d/default.conf && \
    echo '        proxy_set_header Host $host;' >> /etc/nginx/http.d/default.conf && \
    echo '        proxy_set_header X-Real-IP $remote_addr;' >> /etc/nginx/http.d/default.conf && \
    echo '        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;' >> /etc/nginx/http.d/default.conf && \
    echo '    }' >> /etc/nginx/http.d/default.conf && \
    echo '' >> /etc/nginx/http.d/default.conf && \
    echo '    location /auth/authorize {' >> /etc/nginx/http.d/default.conf && \
    echo '        # Serve our own authorize.html, not HA Cores' >> /etc/nginx/http.d/default.conf && \
    echo '        try_files /authorize.html =404;' >> /etc/nginx/http.d/default.conf && \
    echo '    }' >> /etc/nginx/http.d/default.conf && \
    echo '' >> /etc/nginx/http.d/default.conf && \
    echo '    # Proxy local files to Home Assistant Core' >> /etc/nginx/http.d/default.conf && \
    echo '    location /local/ {' >> /etc/nginx/http.d/default.conf && \
    echo '        proxy_pass http://homeassistant:8123/local/;' >> /etc/nginx/http.d/default.conf && \
    echo '        proxy_set_header Host $host;' >> /etc/nginx/http.d/default.conf && \
    echo '    }' >> /etc/nginx/http.d/default.conf && \
    echo '' >> /etc/nginx/http.d/default.conf && \
    echo '    # Proxy HACS files to Home Assistant Core' >> /etc/nginx/http.d/default.conf && \
    echo '    location /hacsfiles/ {' >> /etc/nginx/http.d/default.conf && \
    echo '        proxy_pass http://homeassistant:8123/hacsfiles/;' >> /etc/nginx/http.d/default.conf && \
    echo '        proxy_set_header Host $host;' >> /etc/nginx/http.d/default.conf && \
    echo '    }' >> /etc/nginx/http.d/default.conf && \
    echo '' >> /etc/nginx/http.d/default.conf && \
    echo '    # Serve frontend static files' >> /etc/nginx/http.d/default.conf && \
    echo '    location / {' >> /etc/nginx/http.d/default.conf && \
    echo '        try_files $uri $uri/ /index.html;' >> /etc/nginx/http.d/default.conf && \
    echo '    }' >> /etc/nginx/http.d/default.conf && \
    echo '}' >> /etc/nginx/http.d/default.conf

# Copy run script
COPY eq-frontend/run.sh /
RUN chmod +x /run.sh

EXPOSE 8099

# Start via run.sh
CMD ["/run.sh"]
