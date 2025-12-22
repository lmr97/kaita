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
sudo ln -s $(which nsenter)  /usr/bin/nsenter
sudo ln -s $(which iscsiadm) /usr/bin/iscsiadm
```

## NixOS nodes drop connection after rebuild

Add 8.8.8.8 to the name servers, rebuild, and then you can remove it. The node needs to be reminded of the DNS lookups, I suppose.

## Longhorn raising "Output: nsenter: failed to execute mount: No such file or directory" on the NixOS nodes

The NixOS systems don't have `mount` on the standard Hierarchical File System path (`/usr/bin`), so it needs to be symlinked.

```
sudo ln -s /run/current-system/sw/bin/mount /usr/bin/mount
```

See [https://github.com/longhorn/longhorn/issues/2166#issuecomment-3094699127](this GitHub issue).


## Traefik issues with second Jellyfin server

A Jellyfin server has a certain base URL configured in `<JELLYFIN CONFIG DIR>/config/network.xml`, by the option `NetworkConfiguration.BaseURL`. Every sub-request of the main server will be prefixed with this value. So this value has to match the base of the place in the `archie.zapto.org` API where it is supposed to go.

For instance, even if you configured the second server to have `/jf2` for its root in the Traefik reverse proxy, and the Jellyfin server itself is configured with a base URL of `/jellyfin`, then Traefik will return a 404 error. This is because the Jellyfin server root returns 302 (Found), so it will redirect all requests to, in this example, some page like `/jellyfin/web/...`, which may not exist in the reverse proxy, causing the error. 

## Solutions

- Make the `BaseURL` value reflect the reverse proxy's entrypoint

- Make the `BaseURL` value relative (prefix with `.`)


## Problems with login hanging on `ssh` (for a NixOS node)

The issue seems to be that the NixOS seems to wipe the files in `~/.ssh` sometimes. But, as long as they're on one NixOS node, they can be successfully be copied into the other and resolve the problem. kopaka and gali have essentially equivalent ones (just change the host name), and there is an additional copy on archie and my main laptop, each at `~/nixos-ssh-bkup`

## CrowdSec not alerting on anything

This is because, due to the way Kubernetes is set up, all requests (especially to Traefik) are sent as the cluster's local IP address, and local IPs are automatically whitelisted. The original IP needs to be included in the HTTP request. So, to configure that, add the following to the `traefik-cfg.yaml` file:

```
service:
  spec:
    externalTrafficPolicy: Local 
```

This could also be due to the fact that that access logs (HTTP request logs) are note enabled on k3s by default. To enable those, add this to `traefik-cfg.yaml`:

```
logs:
  access:
    enable: true
    format: common  # could also be `json`
```
