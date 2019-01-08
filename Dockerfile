FROM ubuntu:bionic

# The noninteractive setting makes sure no dialogs are opened and so
# dpkg-reconfigure does not prompt for input
#ARG DEBIAN_FRONTEND=noninteractive
ENV RSTUDIO_DEB rstudio-server-1.1.463-amd64.deb
ENV CRAN_URL https://cloud.r-project.org
ENV CRAN_REPO deb $CRAN_URL/bin/linux/ubuntu bionic-cran35/
ENV RUSER_HOME /home/rstudio

# Update the system and install dependencies
# File badproxy contains a fix for a problem with apt
# (hash sum mismatches when downloading packages)
#COPY ./badproxy /etc/apt/apt.conf.d/99fixbadproxy
RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get install -y --no-install-recommends --no-install-suggests \
      apt-utils gdebi-core lsb-release sudo libapparmor1 psmisc \
      software-properties-common apt-transport-https gnupg wget && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a user for RStudio
RUN useradd -u 10001 -d $RUSER_HOME -g rstudio-server rstudio && \
    echo 'rstudio:rstudio' | chpasswd && \
    mkdir -p $RUSER_HOME/R && \
    chown -R rstudio:rstudio $RUSER_HOME

# Install R
COPY ./cran-r-key.txt /etc/apt/trusted.gpg.d/cran-r-key.asc
RUN add-apt-repository "$R_CRAN_REPO"
RUN apt-get update && \
    apt-get install -y r-base && \
    apt-get clean

# Install RStudio Server
#RUN wget --progress=bar:force https://download2.rstudio.org/$RSTUDIO_DEB
#RUN apt-get install -y gdebi-core && \
#    gdebi -n $RSTUDIO_DEB && \
#    echo "r-cran-repos=${CRAN_URL}" >> /etc/rstudio/rsession.conf

#EXPOSE 8787
#ENTRYPOINT ["/usr/lib/rstudio-server/bin/rserver"]
#CMD ["--server-daemonize=0", "--server-app-armor-enabled=0"]
CMD ["bash"]
