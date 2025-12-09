# Multi-stage build for Equicrew Frontend
# Define ARG at the top level to be available across all stages
ARG BUILD_FROM

# Stage 1: Build the frontend
# Always use amd64 for building (GitHub Actions runners are amd64)
FROM --platform=linux/amd64 node:20-alpine AS builder

WORKDIR /build

# Install build dependencies
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    git

# Copy package files, yarn config and patches
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn/patches .yarn/patches
COPY .yarn/releases .yarn/releases
RUN corepack enable && \
    yarn install --immutable

# Copy source code
COPY . .

# Build frontend
RUN yarn build

# Stage 2: Create the runtime container
# Re-declare ARG for this stage
ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install nginx for serving the frontend
RUN apk add --no-cache nginx

# Copy built frontend from builder stage
COPY --from=builder /build/hass_frontend /usr/share/nginx/html

# Configure nginx
RUN mkdir -p /etc/nginx/http.d && \
    echo 'server {' > /etc/nginx/http.d/default.conf && \
    echo '    listen 8099;' >> /etc/nginx/http.d/default.conf && \
    echo '    root /usr/share/nginx/html;' >> /etc/nginx/http.d/default.conf && \
    echo '    index index.html;' >> /etc/nginx/http.d/default.conf && \
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
