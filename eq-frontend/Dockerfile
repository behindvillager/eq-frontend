# Multi-stage build for Equicrew Frontend
ARG BUILD_FROM

# Stage 1: Build the frontend
FROM --platform=linux/amd64 node:20-alpine AS builder

WORKDIR /build

# Install build dependencies
RUN apk add --no-cache python3 make g++ git bash

# Copy package files, yarn config and patches
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn/patches .yarn/patches
COPY .yarn/releases .yarn/releases
RUN corepack enable && yarn install --immutable

# Copy source code
COPY . .

# Build frontend
RUN yarn build

# Post-process index.html to remove Jinja templates and create manifest
# Use perl for multiline regex replacement
RUN apk add --no-cache perl && \
    perl -i -0pe 's/\{\{ theme_color \}\}/#03a9f4/g' /build/hass_frontend/index.html && \
    perl -i -0pe 's/\{%-\s*for extra_module in extra_modules\s*-%\}.*?\{%-\s*endfor\s*-%\}//gs' /build/hass_frontend/index.html && \
    perl -i -0pe 's/\{%-\s*for extra_script in extra_js_es5\s*-%\}.*?\{%-\s*endfor\s*-%\}//gs' /build/hass_frontend/index.html && \
    echo '{"name":"eq cube","short_name":"eq cube","start_url":"/","display":"standalone","background_color":"#111111","theme_color":"#03a9f4","icons":[{"src":"/static/icons/favicon-192x192.png","sizes":"192x192","type":"image/png"}]}' > /build/hass_frontend/manifest.json

# Stage 2: Create the runtime container
ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install nginx
RUN apk add --no-cache nginx

# Copy built frontend
COPY --from=builder /build/hass_frontend /usr/share/nginx/html

# Copy nginx config
COPY eq-frontend/nginx.conf /etc/nginx/http.d/default.conf

# Copy run script
COPY eq-frontend/run.sh /
RUN chmod +x /run.sh

EXPOSE 8099

CMD ["/run.sh"]
