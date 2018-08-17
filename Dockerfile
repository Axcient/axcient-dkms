ARG tag="ubuntu:trusty"
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
ENV e1000e_version "3.4.0.2"
ENV ixgbe_version "5.3.7"

# Download folders will probably have to be updated when versions are incremented
RUN wget https://downloadmirror.intel.com/15817/eng/e1000e-${e1000e_version}.tar.gz
RUN wget https://downloadmirror.intel.com/14687/eng/ixgbe-${ixgbe_version}.tar.gz

RUN tar xf e1000e-${e1000e_version}.tar.gz -C /usr/src/
RUN tar xf ixgbe-${ixgbe_version}.tar.gz -C /usr/src/
RUN rm *.tar.gz

# Build e1000e
ENV e1000e_conf /usr/src/e1000e-${e1000e_version}/dkms.conf
COPY dkms.conf.template ${e1000e_conf}
RUN sed -i "s/__PACKAGE__/e1000e/g" ${e1000e_conf}
RUN sed -i "s/__VERSION__/${e1000e_version}/g" ${e1000e_conf}

RUN dkms add -m e1000e -v ${e1000e_version}
# Don't build any binaries for now
#RUN dkms build -m e1000e -v ${e1000e_version}
#RUN dkms mkdeb -m e1000e -v ${e1000e_version}
RUN dkms mkdeb --source-only -m e1000e -v ${e1000e_version}

# Build ixgbe
ENV ixgbe_conf /usr/src/ixgbe-${ixgbe_version}/dkms.conf
COPY dkms.conf.template ${ixgbe_conf}
RUN sed -i "s/__PACKAGE__/ixgbe/g" ${ixgbe_conf}
RUN sed -i "s/__VERSION__/${ixgbe_version}/g" ${ixgbe_conf}

RUN dkms add -m ixgbe -v ${ixgbe_version}
# Don't build any binaries for now
#RUN dkms build -m ixgbe -v ${ixgbe_version}
#RUN dkms mkdeb -m ixgbe -v ${ixgbe_version}
RUN dkms mkdeb --source-only -m ixgbe -v ${ixgbe_version}

RUN cp /var/lib/dkms/*/*/deb/* /build/

VOLUME /out

# Copy build packages to volume
CMD cp -a /build/* /out/
