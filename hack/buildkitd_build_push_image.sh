#!/usr/bin/env bash
HIVE_ROOT="$(git rev-parse --show-toplevel)"
CNI_PATH="$HIVE_ROOT"/.tmp/_output/cni/bin
export HIVE_ROOT
export CNI_PATH
export PATH=$HIVE_ROOT/.tmp/_output/bin:$PATH

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

echo "Setup complete. BuildKit is installed and running. Building and pushing the image"

sleep 10

buildctl --addr unix:///run/user/$UID/buildkit/buildkitd.sock build \
    --frontend dockerfile.v0 \
    --local context=. \
    --local dockerfile=. \
    --secret id=docker,src=/home/"$USER"/.docker/config.json \
    --output type=image,name=localhost:5000/hive:latest,push=true
