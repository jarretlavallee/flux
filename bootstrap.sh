#!/bin/bash

# kubeadm init --pod-network-cidr=172.16.0.0/16
# kubectl apply -f system/calico/calico.yaml
# kubectl taint nodes --all node-role.kubernetes.io/master-

# Import the private key (not in this repo)
kubectl apply -f local/sealed-secrets-key.yaml
# Set up Sealed Secrets
helm install --namespace kube-system sealed-secrets stable/sealed-secrets

# Setup Flux
kubectl apply -f flux/namespace.yaml
kubectl apply -f flux/flux-ssh.yaml
helm repo add fluxcd https://charts.fluxcd.io
# https://github.com/fluxcd/flux/issues/3011
helm upgrade -i flux fluxcd/flux \
  --namespace flux \
  --set git.url=ssh://git@github.com/jarretlavallee/flux.git \
  --set git.secretName=flux-ssh \
  --set syncGarbageCollection.enabled=true \
  --version 1.2.0

helm upgrade -i helm-operator fluxcd/helm-operator \
  --namespace flux \
  --set git.ssh.secretName=flux-ssh \
  --set helm.versions=v3
