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


