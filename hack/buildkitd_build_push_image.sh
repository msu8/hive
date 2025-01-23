#!/usr/bin/env bash
HIVE_ROOT="$(git rev-parse --show-toplevel)"
CNI_PATH="$HIVE_ROOT"/.tmp/_output/cni/bin
export HIVE_ROOT
export CNI_PATH
export PATH=$HIVE_ROOT/.tmp/_output/bin:$PATH

# Run BuildKit in the background
echo "Starting BuildKit daemon in the background..."
$ containerd-rootless-setuptool.sh nsenter \
    -- buildkitd \
    --oci-worker=false \
    --containerd-worker=true \
    --containerd-worker-snapshotter=native > /dev/null 2>&1

if pgrep 'buildkitd' > /dev/null; then
 echo "BuildKit daemon is running in the background."
else
 echo "Error: Failed to start BuildKit daemon."
 exit 1
fi

echo "Setup complete. BuildKit is installed and running. Building and pushing the image"

sleep 10

touch "$HIVE_ROOT/.tmp/_output/config.json"

buildctl --addr unix:///run/user/$UID/buildkit/buildkitd.sock build \
  --frontend dockerfile.v0 \
  --local context=. \
  --local dockerfile=. \
  --secret id=docker,src="$HIVE_ROOT/.tmp/_output/config.json" \
  --opt build-arg:EL8_BUILD_IMAGE=registry.ci.openshift.org/openshift/release:golang-1.22 \
  --opt build-arg:EL9_BUILD_IMAGE=registry.ci.openshift.org/openshift/release:golang-1.22 \
  --opt build-arg:BASE_IMAGE=registry.ci.openshift.org/origin/4.16:base \
  --opt build-arg:GO="CGO_ENABLED=0 go" \
  --output type=image,name=localhost:5000/hive:latest,push=true
