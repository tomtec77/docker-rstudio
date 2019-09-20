FROM ubuntu:bionic

ARG DEBIAN_FRONTEND=noninteractive

ENV RUSER_HOME /home/rstudio

# Update the system and install dependencies
# File badproxy contains a fix for a problem with apt
# (hash sum mismatches when downloading packages)
COPY ./badproxy /etc/apt/apt.conf.d/99fixbadproxy
RUN apt-get update && \
#    apt-get -y dist-upgrade && \
	apt-get install -y --no-install-recommends --no-install-suggests \
	apt-utils \
	gdebi-core \
	git \
	lsb-release \
	sudo \
	libapparmor1 \
	psmisc \
	locales \
	software-properties-common \
	apt-transport-https \
	gnupg \
	libcurl4-openssl-dev \
	libxml2-dev \
	libssl-dev \
	wget

# Clean up
RUN apt-get -y autoremove && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

# Install R
ENV CRAN_URL https://cloud.r-project.org
ENV CRAN_REPO deb $CRAN_URL/bin/linux/ubuntu bionic-cran35/

COPY ./cran-r-key-ubuntu.txt /etc/apt/trusted.gpg.d/cran-r-key.asc

RUN add-apt-repository "$CRAN_REPO"
RUN apt-get update && \
    apt-get install -y r-base && \
    apt-get clean

# Install some R packages
# Generally useful
RUN R -e "install.packages('tidyverse', dependencies=TRUE, repos='$CRAN_URL')"
# For package management
RUN R -e "install.packages('packrat', dependencies=TRUE, repos='$CRAN_URL')"
# For notebooks or presentations
RUN R -e "install.packages('digest', dependencies=TRUE, repos='$CRAN_URL')"
# For Shiny
RUN R -e "install.packages('shiny', dependencies=TRUE, repos='$CRAN_URL')"

# Create a default user. Available via runtime flag '--user rstudio'
# Add user to 'staff' group, granting them write privileges to
# /usr/local/lib/R/site.library
# User should also have and own a home directory for rstudio or linked
# volumes to work properly
RUN useradd -d $RUSER_HOME -s /bin/bash -u 10000 -U -p rstudio rstudio && \
    mkdir -p $RUSER_HOME/R && \
    addgroup rstudio staff && \
    echo 'rstudio:rstudio' | chpasswd

RUN chown -R rstudio:rstudio $RUSER_HOME

# Create a shared directory
RUN mkdir /share && \
	chown -R rstudio:rstudio /share

# Configure default locale
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_US.utf8 && \
    /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# Install RStudio Server
ENV RSTUDIO_URL https://download2.rstudio.org/server/bionic/amd64
ENV RSTUDIO_DEB rstudio-server-1.2.5001-amd64.deb

RUN wget --progress=bar:force $RSTUDIO_URL/$RSTUDIO_DEB
RUN gdebi -n $RSTUDIO_DEB && \
    echo "r-cran-repos=${CRAN_URL}" >> /etc/rstudio/rsession.conf

EXPOSE 8787
VOLUME /share

ENTRYPOINT ["/usr/lib/rstudio-server/bin/rserver"]

#CMD ["/bin/bash"]
CMD ["--server-daemonize=0", "--server-app-armor-enabled=0"]
