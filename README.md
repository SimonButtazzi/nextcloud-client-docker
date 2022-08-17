# Nextcloud docker-client
This image provides you an alpine based image for syncing your files with a remote [nextcloud server ](https://nextcloud.com/)

[![](https://images.microbadger.com/badges/image/juanitomint/nextcloud-client.svg)](https://microbadger.com/images/juanitomint/nextcloud-client "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/juanitomint/nextcloud-client.svg)](https://microbadger.com/images/juanitomint/nextcloud-client "Get your own version badge on microbadger.com")

This image is based on the work made by: [Martin Peters](https://github.com/FreakyBytes)

## Example using local folder

    docker run -it --rm \
      -v $(pwd)/sync-folder:/media/nextcloud \
      -e NC_USER=$username -e NC_PASS=$password \
      -e NC_URL=$server_url\
      juanitomint/nextcloud-client

## Example using local folder and exclude settings. You have to place a "exclude" file and a "unsyncfolders" file into one directory and mount it into the docker container

    docker run -it --rm \
      -v $(pwd)/sync-folder:/media/nextcloud \
      -v /path/to/settingsfolder:/settings \
      -e NC_USER=$username -e NC_PASS=$password \
      -e NC_URL=$server_url\
      juanitomint/nextcloud-client

## Example for the file "exclude" in the settings folder

    file1
    file2

## Example for the file "unsyncfolders" in the settings folder

    folder1
    folder2

## Example using a [named volume](https://docs.docker.com/storage/volumes/)

    docker run -it --rm \
      -v some_named_volume:/media/nextcloud \
      -e NC_USER=$username -e NC_PASS=$password \
      -e NC_URL=$server_url\
      juanitomint/nextcloud-client

## Example one time run

    docker run -it --rm \
      -v some_named_volume:/media/nextcloud \
      -e NC_USER=$username -e NC_PASS=$password \
      -e NC_URL=$server_url\
      -e NC_EXIT=true\
      juanitomint/nextcloud-client


replace:
 * $username
 * $password 
 * $server_url 
 
 with valid values for an existing and valid user on a Nextcloud Server.

## ENV variables to customize your deploy

##### NC_URL
URL to the Nextcloud instance. Specify only the base URL of your host. Example: `https://cloud.example.com`.

##### NC_USER
The user name to log in

##### NC_PASS 
Valid password for the user above in clear text

##### NC_SOURCE_DIR
The directory inside de docker container to be synced, usually you will have a local mount here or a named volume

default: `/media/nextcloud/`

##### NC_PATH
You can sync specific folders by providing the full path like `/path/to/custom/dir`. This will only sync the contents of this folder inside `$NC_SOURCE_DIR`.

default: "" i.e. root folder

##### NC_SILENT
Whether or not output activity to console

default: `false`

##### NC_INTERVAL
Sets the interval in seconds between syncs in seconds

default: `300` (300 /60 = 5 Minutes)

##### NC_EXIT
If "true" the sync will happen once and then the container will exit, very usefull for using 
in conjunction with cron or schedulers

default: `false` 

## Advanced settings

##### USER
The system user inside the container you want to use for runing the sync

default: `ncsync`

##### USER_GID
The system user group id inside the container you want to use for runing the sync

default: `1000`

##### USER_UID
The system user id inside the container you want to use for runing the sync

default: `1000`

##### NC_TRUST_CERT
Whether or not trust self signed certificates or invalid certificates

default: `false`

##### NC_HIDDEN
Whether or not nextcloud should be forced to sync hidden files

default: `false`

##### WATCH_FOLDER
If `true` the sync will be triggered by a file change OR after timeout defined by NC_INTERVAL. Reduces polling without waiting to push local changes immediately.
This is very usefull for saving resources if there are not much local changes by increasing NC_INTERVAL.

default: `false`

##### NC_DELAY
Seconds to wait after a sync was triggered by file change (WATCH_FOLDER=true)
Prevents sync to run too often. Also usefull to make sure a file was written completely instead of syncing partial files (e.g. new-file.zip.part).

default: `5`

---
Any comment or problem? Feel free to [fill an issue](https://github.com/juanitomint/nextcloud-client-docker/issues/new) or make a PR!
