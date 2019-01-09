# docker-rstudio

Docker container to run R and RStudio Server.

The Dockerfile pulls an Ubuntu 18.04 container and installs R, RStudio Server and
several dependencies.

RStudio Server runs on port 8787 of the container, so you need to map it to a 
port in the host.

To run the server:

``` bash
docker run -p 8787:8787 tomtec/docker-rstudio
```

Point a browser to http://localhost:8787 and log in to RStudio with username and
password `rstudio`.


