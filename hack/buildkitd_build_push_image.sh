#!/bin/bash

# Run BuildKit in the background
echo "Starting BuildKit daemon in the background..."
rootlesskit buildkitd > /dev/null 2>&1 &
BUILDKIT_PID=$!

if ps -p $BUILDKIT_PID > /dev/null; then
 echo "BuildKit daemon is running in the background (PID: $BUILDKIT_PID)."
else
 echo "Error: Failed to start BuildKit daemon."
 exit 1
fi

# Edit registry URL according to buildkitd requirements
sed -i 's/\.org:443/\.org\/v1\//g' ~/.docker/config.json

echo "Setup complete. BuildKit is installed and running."

