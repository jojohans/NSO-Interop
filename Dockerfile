# ConfD examples
#
# We use the standard ubuntu bas image.
FROM ubuntu:19.04
LABEL description="Docker image for NETCONF and YANG interop testing with NSO." maintainer="jojohans@cisco.com"

# Install the extra packages we need to run NSO, pioneer and DrNED
# Examiner. Only libssl is actually necessary for NSO itself, the
# python packages are for DrNED Examiner and DrNED.  The rest of the
# packages help us better understand what's going on inside the
# container and meassure network and other I/O performance.
RUN apt-get update && apt-get install -y \
        default-jre-headless \
        git \
        libssl-dev \
        make \
        openssh-client \
        python-lxml \
        python-paramiko \
        python-pexpect \
        python-pytest \
        libxml2-utils \
        xsltproc

#RUN apt-get update && apt-get install -y \
#    git \
#    iperf3 \
#    libssl-dev \
#    net-tools \
#    netcat-openbsd \
#    python-paramiko \
#    strace \
#    tcpdump \
#    vim

# Install NSO

# What ncsrc usually does...
ENV NCS_DIR=/nso LD_LIBRARY_PATH=/nso/lib PATH=/nso/bin:$PATH PYTHONPATH=/nso/src/ncs/pyapi

## Install ConfD in the container.  This is not a regular target
## installation, instead it's only the files required for a minimal
## target installation as described in section 28.3. Installing ConfD
## on a target system in the ConfD User Guide.
#COPY confd-target.tgz /tmp
#RUN mkdir -p ${NCS_DIR}
COPY resources/nso-5.1.0.1.linux.x86_64.signed.bin /tmp
RUN (cd /tmp && ./nso-5.1.0.1.linux.x86_64.signed.bin)
RUN /tmp/nso-5.1.0.1.linux.x86_64.installer.bin $NCS_DIR
RUN ncs-setup --dest /nso/interop --no-netsim

# Install pioneer and drned-xmnr
RUN (cd nso/interop/packages && git clone https://github.com/NSO-developer/pioneer.git)
RUN (cd nso/interop/packages && git clone https://github.com/NSO-developer/drned-xmnr.git)
RUN (cd nso/interop/packages/pioneer/src && make clean all)
RUN (cd nso/interop/packages/drned-xmnr/src && make clean all)

# Enable verbose logging
COPY resources/init.xml /nso/interop/ncs-cdb

# Set working directory for the ConfD daemon to the top directory of the
# mounted example.
WORKDIR /nso/interop

# Initially we only expose NETCONF (over ssh) and IPC ports.
# Uncomment to expose ports for other northbound protocols as
# necessary.
EXPOSE 2022 2023 2024 4565 8008 8088

# Cleanup
RUN apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Start init daemon and ConfD.
#ENTRYPOINT ["/usr/local/sbin/dumb-init", "--"]
CMD ["/nso/bin/ncs", "--foreground", "-v", "--addloadpath", "/nso/interop"]
#CMD ["/nso/bin/ncs_cli", "-C", "-u", "admin", "/tmp/setup-interop.txt"]
