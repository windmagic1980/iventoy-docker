ARG UBUNTU_VERSION="jammy"

# Use build stage to reduce final image
FROM ubuntu:${UBUNTU_VERSION} as build
ARG IVENTOY_VERSION="1.0.08"
ARG IVENTOY_DIR="/opt/iventoy"
ARG IVENTOY_URL="https://github.com/ventoy/PXE/releases/download/v1.0.08/iventoy-1.0.08-linux.tar.gz"
ARG INVENTOY_CHECKSUM="bab21162703190ba2384bddce72f29aee10d63af9655968a8137f2ed48f681f2"

ADD ${IVENTOY_URL} /

RUN echo "${INVENTOY_CHECKSUM} iventoy-${IVENTOY_VERSION}-linux.tar.gz" | sha256sum --check

RUN tar xzf /iventoy-${IVENTOY_VERSION}-linux.tar.gz
RUN mv /iventoy-${IVENTOY_VERSION} ${IVENTOY_DIR}

# Build final image
FROM ubuntu:${UBUNTU_VERSION}
ARG BUILD_VERSION="1"
ARG IVENTOY_VERSION="1.0.08"
ARG IVENTOY_DIR="/opt/iventoy"
ENV IVENTOY_DIR_ENV=${IVENTOY_DIR}

LABEL maintainer="joeclifford - git@cliffsy.co.uk"
LABEL Name=iventoy
LABEL iventoy_Version=${IVENTOY_VERSION}
LABEL BUILD ${BUILD_VERSION}

RUN apt-get update && \
    apt-get install apt-utils -y && \
    rm -rf /var/lib/apt/lists/* 

RUN apt-get update && \
    apt-get install bash grep -y && \
    rm -rf /var/lib/apt/lists/* 

# Install some tools useful for diag
RUN apt-get update && \
    apt-get install less ncat curl wget net-tools procps iproute2 -y && \
    rm -rf /var/lib/apt/lists/* 

COPY --from=build ${IVENTOY_DIR} ${IVENTOY_DIR}
COPY --from=build ${IVENTOY_DIR}/data ${IVENTOY_DIR}/default_files/data
COPY --from=build ${IVENTOY_DIR}/user ${IVENTOY_DIR}/default_files/user

COPY files/docker-entrypoint.sh ${IVENTOY_DIR}/docker-entrypoint.sh

RUN chmod +x ${IVENTOY_DIR}/docker-entrypoint.sh

VOLUME ${IVENTOY_DIR}/data
VOLUME ${IVENTOY_DIR}/iso
VOLUME ${IVENTOY_DIR}/user

WORKDIR ${IVENTOY_DIR}

ENTRYPOINT ["/bin/bash", "-c", "$IVENTOY_DIR_ENV/docker-entrypoint.sh"]

# DHCP server port
EXPOSE 67/udp
# tftp server port
EXPOSE 69/tcp
# NBD server port
EXPOSE 10809/tcp
# iventoy HTTP port
EXPOSE 16000/tcp  
# iventoy Mgmt port  
EXPOSE 26000/tcp
