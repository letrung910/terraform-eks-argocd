alias kl='kubectl logs deploy/karpenter -n karpenter -f --tail=20'

kubectl get node -l karpenter.sh/provisioner-name