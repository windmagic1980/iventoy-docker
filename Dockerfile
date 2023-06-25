ARG UBUNTU_VERSION="jammy"

FROM ubuntu:${UBUNTU_VERSION}

ENV IVENTOY_VERSION="1.0.03"

LABEL maintainer="joeclifford - git@cliffsy.co.uk"
LABEL Name=iventoy
LABEL Version=$IVENTOY_VERSION

RUN apt-get update && \
    apt-get install apt-utils -y && \
    rm -rf /var/lib/apt/lists/* 

RUN apt-get update && \
    apt-get install bash grep -y && \
    rm -rf /var/lib/apt/lists/* 

ADD iventoy-1.0.03-linux.tar.gz /opt/

RUN mv /opt/iventoy-${IVENTOY_VERSION} /opt/iventoy

COPY docker-entrypoint.sh /opt/iventoy/docker-entrypoint.sh

RUN chmod +x /opt/iventoy/docker-entrypoint.sh

WORKDIR /opt/iventoy

ENTRYPOINT ["/opt/iventoy/docker-entrypoint.sh"]
