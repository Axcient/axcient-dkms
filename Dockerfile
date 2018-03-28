ARG tag="ubuntu:precise"
FROM ${tag}

# Set locale to fix character encoding
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 16126D3A3E5C1192

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies and utilities
RUN apt-get update && apt-get install -y \
  apt-src \
  aptitude \
  devscripts \
  debian-keyring \
  debhelper \
  equivs \
  less \
  locales \
  software-properties-common \
  sudo \
  wget \
  vim \
  quilt\
  dkms

WORKDIR /build

# Versions to download and build
ARG e1000e="3.4.0.2"
ARG ixgbe="5.3.6"

# Download folders will probably have to be updated when versions are incremented
RUN wget https://downloadmirror.intel.com/15817/eng/e1000e-${e1000e}.tar.gz
RUN wget https://downloadmirror.intel.com/14687/eng/ixgbe-${ixgbe}.tar.gz

RUN tar xf e1000e-${e1000e}.tar.gz -C /usr/src/
RUN tar xf ixgbe-${ixgbe}.tar.gz -C /usr/src/
RUN rm *.tar.gz

# Build e1000e
COPY dkms_e1000e.conf /usr/src/e1000e-${e1000e}/dkms.conf
RUN dkms add -m e1000e -v ${e1000e}
# Don't build any binaries for now
#RUN dkms build -m e1000e -v ${e1000e}
#RUN dkms mkdeb -m e1000e -v ${e1000e}
RUN dkms mkdeb --source-only -m e1000e -v ${e1000e}

# Build ixgbe
COPY dkms_ixgbe.conf /usr/src/ixgbe-${ixgbe}/dkms.conf
RUN dkms add -m ixgbe -v ${ixgbe}
# Don't build any binaries for now
#RUN dkms build -m ixgbe -v ${ixgbe}
#RUN dkms mkdeb -m ixgbe -v ${ixgbe}
RUN dkms mkdeb --source-only -m ixgbe -v ${ixgbe}

RUN cp /var/lib/dkms/*/*/deb/* /build/

VOLUME /out

# Copy build packages to volume
CMD cp -a /build/* /out/
