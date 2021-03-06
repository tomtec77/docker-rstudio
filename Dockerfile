FROM ubuntu:bionic

ARG DEBIAN_FRONTEND=noninteractive

ENV NAME rstudio
ENV RUSER_HOME /home/rstudio

# Update the system and install dependencies
RUN apt-get update && apt-get install -y \
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
	libclang-dev \
	libcurl4-openssl-dev \
	libxml2-dev \
	libssl-dev \
	wget \
	&& rm -rf /var/lib/apt/lists/*

# Install R
ENV CRAN_URL https://cloud.r-project.org
ENV CRAN_REPO deb $CRAN_URL/bin/linux/ubuntu bionic-cran35/

COPY ./cran-r-key-ubuntu.txt /etc/apt/trusted.gpg.d/cran-r-key.asc

RUN add-apt-repository "$CRAN_REPO"
RUN apt-get update && apt-get install -y r-base \
	&& rm -rf /var/lib/apt/lists/*

# Create a default user. Available via runtime flag '--user rstudio'
# Add user to 'staff' group, granting them write privileges to
# /usr/local/lib/R/site.library
# User should also have and own a home directory for rstudio or linked
# volumes to work properly
RUN useradd -d $RUSER_HOME -s /bin/bash -u 10000 -U -p $NAME $NAME && \
    mkdir -p $RUSER_HOME/R && \
    addgroup $NAME staff && \
    echo "rstudio:rstudio" | chpasswd

RUN chown -R $NAME:$NAME $RUSER_HOME

#RUN cp /etc/pam.d/login /etc/pam.d/$NAME

# Create a shared directory
RUN mkdir /share && \
	chown -R $NAME:$NAME /share

# Configure default locale
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_US.utf8 && \
    /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# Install RStudio Server
ENV RSTUDIO_URL https://download2.rstudio.org/server/bionic/amd64
ENV RSTUDIO_DEB rstudio-server-1.2.5033-amd64.deb

RUN wget --progress=bar:force $RSTUDIO_URL/$RSTUDIO_DEB
RUN gdebi -n $RSTUDIO_DEB && \
    echo "r-cran-repos=${CRAN_URL}" >> /etc/rstudio/rsession.conf

EXPOSE 8787
VOLUME /share

ENTRYPOINT ["/usr/lib/rstudio-server/bin/rserver"]

#CMD ["/bin/bash"]
CMD ["--server-daemonize=0", "--server-app-armor-enabled=0"]
