#!/usr/bin/env bash

set -o errexit

HIVE_ROOT="$(git rev-parse --show-toplevel)"
export CNI_PATH=$HIVE_ROOT/.tmp/_output/bin/cni/bin

cluster_name="${1:-hive}"

reg_name='kind-nerdctl-registry'

reg_port='5000'


cat <<EOF | KIND_EXPERIMENTAL_PROVIDER="nerdctl" kind create cluster --name "${cluster_name}" --kubeconfig "${HIVE_ROOT}"/.kube/"${cluster_name}".kubeconfig --config=-

kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
 [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${reg_port}"]
   endpoint = ["http://${reg_name}:${reg_port}"]
EOF