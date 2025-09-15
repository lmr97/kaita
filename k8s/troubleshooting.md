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

