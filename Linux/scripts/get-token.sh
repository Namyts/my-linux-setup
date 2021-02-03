#!/bin/bash

token=$(microk8s.kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
microk8s.kubectl -n kube-system describe secret $token | awk '/^[[]/{f=0} /token:/{f=1} f' | grep -v ca.crt | grep -v namespace | sed "s/token:      //g"

#kubectl port-forward -n kube-system service/kubernetes-dashboard 5000:443
