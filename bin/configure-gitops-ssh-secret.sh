#!/bin/bash

set -e

TMP_FOLDER=$(mktemp -d)
trap "rm -rf $TMP_FOLDER" EXIT

GIT_REPO_HOSTNAME=github.com
SECRET_NAME=tap-gitops-ssh-auth

if kubectl get secret "$SECRET_NAME" &> /dev/null ; then
    kubectl get secret "$SECRET_NAME" -o yaml | yq '.data["identity.pub"]' | base64 -d
    exit 0
fi

ssh-keygen \
    -t rsa \
    -C "tap-gitops-ssh-auth" \
    -N "" \
    -f "$TMP_FOLDER/id_rsa"

INDENTED_PRIVATE_KEY=$(sed 's/^/    /' "$TMP_FOLDER/id_rsa")
INDENTED_PUBLIC_KEY=$(sed 's/^/    /' "$TMP_FOLDER/id_rsa.pub")

cat <<EOF | kubectl apply -f -
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scc-gitops-vs-regops.html#ssh-4
apiVersion: v1
kind: Secret
metadata:
  name: $SECRET_NAME # it must match the "gitops_ssh_secret" params in the workload
  annotations:
    tekton.dev/git-0: $GIT_REPO_HOSTNAME # make sure is just the hostname, no protocol
type: kubernetes.io/ssh-auth
stringData:
  ssh-privatekey: |
$INDENTED_PRIVATE_KEY
  identity: |
$INDENTED_PRIVATE_KEY
  identity.pub: |
$INDENTED_PUBLIC_KEY
  known_hosts: |
    github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
    github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
    github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=

EOF

cat "$TMP_FOLDER/id_rsa.pub"
