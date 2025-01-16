#!/usr/bin/env bash

export HIVE_ROOT="$(git rev-parse --show-toplevel)"
export PATH=$HIVE_ROOT/.tmp/_output/bin:$PATH

containerd_pids=$(nerdctl ps -q)

for pid in $container_pids; do
  nerdctl stop "$container_id"
  nerdctl remove "$container_id"
done

nerdctl system prune -a -f

containerd-rootless-setuptool.sh uninstall
rootlesskit rm -rf ~/.local/share/containerd
rootlesskit rm -rf ~/.local/share/nerdctl


buildkitd_pids=$(pgrep -f 'buildkitd')


for pid in $buildkitd_pids; do
  kill $pid
done
