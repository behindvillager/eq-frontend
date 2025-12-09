#!/usr/bin/with-contenv bashio
# ==============================================================================
# Equicrew Frontend Add-on
# Starts nginx to serve the custom frontend
# ==============================================================================

bashio::log.info "Starting Equicrew Frontend..."

# Start nginx in foreground
exec nginx -g "daemon off;"
