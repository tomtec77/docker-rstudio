# docker-rstudio

Docker image to run R and RStudio Server.

The Dockerfile pulls an Ubuntu 18.04 container and installs R, RStudio Server and
several dependencies.

RStudio Server runs on port 8787 of the container, so you need to map it to a 
port in the host.

## Shared directory

To avoid permissions issues, you need to give ownership of the shared volume to 
user `rstudio` in the container. For that, you need to do the following on the
host machine: create the directory to share, then change its ownership using the
numeric user and group IDs to match those of the user in the container (which is
10000 for `rstudio`).

``` bash
sudo chown -R 10000:10000 /your/shared/directory
```

To run the server:

``` bash
docker run -p 8787:8787 -v /your/shared/directory:/share tomtec/rstudioserver
```

Point a browser to http://localhost:8787 and log in to RStudio with username and
password `rstudio`.


