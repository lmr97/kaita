# Troubleshooting

## Failure to get SSL certificates

This is because of the IP tables routing rules added by Kubernetes (via k3s). The certificates cannot be retrieved while the cluster is running, so it needs to be stopped temporarily. All cluster data/settings/containers will be preserved. To clear out these rules:

1. Stop the `k3s` service: 
    
    ```
    sudo systemctl stop k3s
    ```

2. Run the k3s cleanup script:
    
    ```
    k3s-killall.sh
    ```

3. Get the certificate:

    ```
    sudo certbot certonly --standalone -d archie.zapto.org
    ```

4. Restart the cluster:

    ```
    sudo systemctl start k3s
    ```

## Gateway Timeout (HTTP status 504) issues

It's been the firewall. Make sure to enable these ports/IPs to let the content flow:

```
sudo ufw allow from 10.42.0.0/16 to any
sudo ufw allow from 10.43.0.0/16 to any
sudo ufw allow 2379
sudo ufw allow 2380
sudo ufw allow 8472
```

(Some of these may be redundant, but I know at least one of these solved the issue.)

## Persmissions issues in generating Ceph PVs

New secrets for the storage class need to be generated. 

1. Delete the secrets (these come from the `ceph-storage-class.yaml` file):

```
kubectl delete secret rook-csi-cephfs-node
kubectl delete secret rook-csi-cephfs-provisioner
```

2. Delete the `rook-cephfs` storage class

```
kubectl delete -f ceph-storage-class.yaml
```

3. Recreate the storage class

```
kubectl create -f ceph-storage-class.yaml
```

## Jellyfin server shuts down after a set amount of movie playback

The issue is with the cache size, which, in the deployment, is an `EmptyDir` volume with a set size. Simply increase the size in the definition and apply.


## Longhorn Manager throwing an error about iscsiadm/open-iscsi not being installed (when it is)

This is an issue with where NixOS places its binaries by default: it places them somewhere under the `/run` directory, not in `/usr/bin`. So simply sym-link the `nsenter` and `iscsiadm` executables to the expected path:

```
sudo ln -s $(which nsenter) /usr/bin/nsenter
sudo ln -s $(which iscsiadm) /usr/bin/iscsiadm
```

## NixOS nodes drop connection after rebuild

Add 8.8.8.8 to the name servers, rebuild, and then you can remove it. The node needs to be reminded of the DNS lookups, I suppose.


