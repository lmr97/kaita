kubectl delete secret -n rook-ceph rook-csi-cephfs-node
kubectl delete secret -n rook-ceph rook-csi-cephfs-provisioner
kubectl apply -f ceph-storage-class.yaml
