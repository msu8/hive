#!/usr/bin/env bash

HIVE_ROOT="$(git rev-parse --show-toplevel)"
export HIVE_ROOT
export PATH=$HIVE_ROOT/.tmp/_output/bin:$PATH

containerd_pids=$(nerdctl ps -q)

for pid in $containerd_pids; do
  nerdctl stop "$pid"
  nerdctl remove "$pid"
done

nerdctl system prune -a -f

containerd-rootless-setuptool.sh uninstall
rootlesskit rm -rf ~/.local/share/containerd
rootlesskit rm -rf ~/.local/share/nerdctl

buildkitd_pids=$(pgrep -f 'buildkitd')

for pid in $buildkitd_pids; do
  kill "$pid"
done

sudo rm -rf "$HIVE_ROOT"/.tmp "$HIVE_ROOT"/.kube "$HIVE_ROOT"/hiveadmission-certs