#!/bin/sh

# Check if BACKEND_ADDRESS is set
if [ -z "$BACKEND_ADDRESS" ]; then
  echo "Error: BACKEND_ADDRESS environment variable is not set."
  exit 1
fi

# Replace the placeholder with the backend address
sed -i "s/<BACKEND_ADDRESS>/${BACKEND_ADDRESS}/g" /usr/share/nginx/html/index.js

# Start Nginx
nginx -g "daemon off;"
