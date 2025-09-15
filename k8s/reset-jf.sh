#!/bin/sh
kubectl delete ingressroute -n archie main-rev-prox
kubectl delete service -n archie jellyfin
kubectl delete deployment -n archie jellyfin
kubectl delete pvc -n archie jellyfin-media-pvc
kubectl delete pvc -n archie jellyfin-cfg-pvc
kubectl delete pv  -n archie jellyfin-media-vol
kubectl delete pv  -n archie jellyfin-cfg-vol
kubectl apply -f jellyfin-pv-pvc.yaml
kubectl apply -f jellyfin-service.yaml
kubectl apply -f rev-prox.yaml
