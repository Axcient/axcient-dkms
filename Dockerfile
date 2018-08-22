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
ENV mpt3sas_version "22.00.00.00"

# Package containing many things including the actual mpt3sas source
ENV mpt3sas_zip_version "RHEL6-7_SLES11-12_P15"

RUN wget https://downloadmirror.intel.com/15817/eng/e1000e-${e1000e_version}.tar.gz
RUN wget https://downloadmirror.intel.com/14687/eng/ixgbe-${ixgbe_version}.tar.gz
ENV mpt3sas Linux_Driver_${mpt3sas_zip_version}
RUN wget https://www.supermicro.com/wftp/driver/SAS/LSI/3224/Driver/Linux/${mpt3sas}.zip

# Extract mpt3sas
# The actual source package is a few levels deep
RUN unzip ${mpt3sas}.zip \
  && rm *.zip

RUN mkdir /tmp/sas
RUN tar xf ${mpt3sas}/mpt3sas_rhel5_rel/mpt3sas-release.tar.gz -C /tmp/sas/ \
  && rm -rf ${mpt3sas}

RUN tar xf /tmp/sas/mpt3sas-${mpt3sas_version}-src.tar.gz -C /usr/src/ \
  && mv /usr/src/mpt3sas /usr/src/mpt3sas-${mpt3sas_version} \
  && rm -rf /tmp/sas/

# Extract NIC drivers
RUN tar xf e1000e-${e1000e_version}.tar.gz -C /usr/src/ \
  && tar xf ixgbe-${ixgbe_version}.tar.gz -C /usr/src/ \
  && rm *.tar.gz

# Build mpt3sas
ENV mpt3sas_conf /usr/src/mpt3sas-${mpt3sas_version}/dkms.conf
COPY dkms.conf.mpt3sas ${mpt3sas_conf}
RUN sed -i "s/__PACKAGE__/mpt3sas/g" ${mpt3sas_conf}
RUN sed -i "s/__VERSION__/${mpt3sas_version}/g" ${mpt3sas_conf}

RUN dkms add -m mpt3sas -v ${mpt3sas_version}
RUN dkms mkdeb --source-only -m mpt3sas -v ${mpt3sas_version}

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
