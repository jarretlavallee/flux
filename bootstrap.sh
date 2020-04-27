#!/bin/bash

# kubeadm init --pod-network-cidr=192.168.0.0/16
# kubectl apply -f system/calico/calico.yaml
# kubectl taint nodes --all node-role.kubernetes.io/master-

# Import the private key (not in this repo)
kubectl apply -f local/sealed-secrets-key.yaml
# Set up Sealed Secrets
helm install --namespace kube-system sealed-secrets stable/sealed-secrets

# Setup Flux
kubectl apply -f namespaces/flux.yaml
kubectl apply -f flux/flux-git-deploy.yaml
helm repo add fluxcd https://charts.fluxcd.io
helm upgrade -i flux fluxcd/flux \
  --namespace flux \
  --set git.url=git@github.com:jarretlavallee/flux \
  --set syncGarbageCollection.enabled=true

helm upgrade -i helm-operator fluxcd/helm-operator \
  --namespace flux \
  --set git.ssh.secretName=flux-git-deploy \
  --set helm.versions=v3
