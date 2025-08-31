# Troubleshooting

### *cuz my stupid ass needs these notes*

## Server not reachable at port 8096 on localhost

Ports need to be explicitly bound, at least with a rootless Docker run.

After you change `compose.yaml`, be sure to use 

    ```  
    docker compose down 
    docker compose up -d
    ```
not

    ```
    docker compose restart
    ```

Restarting the container, even with a changed Compose file, does NOT apply new port settings.

## Standard Definition DVDs not reading

Load the `sg` kernel module: `sudo modprobe sg`.

## Jellyfin.Server.Migrations.JellyfinMigrationService: Failed to apply migrationsjellyfin error

Simply delete `~/.config/jellyfin/config/migrations.xml`. It is unnecessary and likely reflects database corruption if it's giving issues. Last time I had this issue was after I manually edited the database to try and solve a different problem with an older Docker image. It was unnecessary, and caused this issue.

## Cannot find <some table>

This is usually because the `library.db` file got corrupted somehow. 

1. Copy a fresh `migrations.xml` from `/var/lib/jellyfin`

2. Delete the existing `library.db`.

3. In `config/system.xml`, set `<IsSetupWizardComplete>` to `false`.

4. Start up the server.

5. Shut it down once it start successfully.

6. Change `<IsSetupWizardComplete>` back to `true`.

7. Spin up the server again.


## Server crashing on library scan

Limit the number of threads used for the library scan. In the web UI, go to Dashboard > General > Server > Parallel library scan tasks limit, and set the value to 1. This compromises performance, of course, but increases reliability.
