FROM debian:stretch

# The noninteractive setting makes sure no dialogs are opened and so
# dpkg-reconfigure does not prompt for input
ARG DEBIAN_FRONTEND=noninteractive
ENV RSTUDIO_DEB rstudio-server-stretch-1.1.463-amd64.deb
ENV R_CRAN_REPO deb https://cloud.r-project.org/bin/linux/debian stretch-cran35/
ENV RUSER_HOME /home/ruser

# Update the system and install dependencies
# File badproxy contains a fix for a problem with apt
# (hash sum mismatches when downloading packages)
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends apt-utils

COPY ./badproxy /etc/apt/apt.conf.d/99fixbadproxy

RUN apt-get install -y software-properties-common apt-transport-https gnupg

# Create a user for RStudio
RUN useradd -u 10001 -d $RUSER_HOME ruser && \
    echo 'ruser:docker' | chpasswd && \
    mkdir -p $RUSER_HOME/R && \
    chown -R ruser:ruser $RUSER_HOME

# Install R
COPY ./debian-r-key.txt /etc/apt/trusted.gpg.d/debian-r-key.asc
RUN add-apt-repository "$R_CRAN_REPO"
RUN apt-get update && \
    apt-get install -y r-base

# Install RStudio Server
RUN apt-get install -y wget
RUN wget --progress=bar:force https://download2.rstudio.org/$RSTUDIO_DEB
RUN apt-get install -y gdebi-core && \
    gdebi -n $RSTUDIO_DEB

EXPOSE 8787
ENTRYPOINT ["/usr/lib/rstudio-server/bin/rserver"]
CMD ["--server-daemonize=0", "--server-app-armor-enabled=0"]
