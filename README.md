# docker-rstudio

Docker image to run R and RStudio Server.

The Dockerfile pulls an Ubuntu 18.04 image and installs R, RStudio Server and
several dependencies on it. It also creates a regular, non-sudo user for the
server, named`rstudio`.

RStudio Server runs on port 8787 of the container.

Build the image with:

``` bash
sudo docker build . -t tomtec/rserver
```

## Shared directory

To avoid permissions issues, you need to give ownership of the shared volume to 
user `rstudio` in the container. For that, you need to do the following on the
host machine: create the directory to share, then change its ownership using the
numeric user and group IDs to match those of the user in the container (which is
10000 for `rstudio`).

``` bash
sudo chown -R 10000:10000 /your/shared/directory
```

## Running a container

To run the server:

``` bash
sudo docker run --rm -p 8787:8787 -v /your/shared/directory:/share tomtec/rserver
```

Point a browser to http://localhost:8787 and log in to RStudio with username and
password `rstudio`.

With the `--rm` option the container is deleted once it finishes running. When
you are done working with it, to stop the container first find out its ID with 
`sudo docker ps` and then run

``` bash
sudo docker stop <container ID>
```
