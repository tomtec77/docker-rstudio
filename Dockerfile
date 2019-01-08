FROM debian

RUN apt-get update
RUN \
    apt-get -y dist-upgrade &&
    apt-get install -y dirmngr --install-recommends && \
    apt-get install -y software-properties-common apt-transport-https

# Install R
RUN apt-key adv --keyserver keys.gnupg.net --recv-key 'E19F5F87128899B192B1A2C2AD5F960A256A04AF'
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/debian stretch-cran35/'

CMD ["bash"]