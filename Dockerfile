# 2022-08-12 00:27:51

FROM registry.hub.docker.com/library/node:alpine as build

LABEL mantainer="Gaspare Iengo <gaspare@katapy.com>"
RUN \
  apk add --no-cache --update fuse3 && \
  rm -rf /tmp/*

WORKDIR /usr/bin
RUN ln -sfnv fusermount3 fusermount

####
# Install Docker volume driver API server
####

# Create directories for mounts
RUN mkdir -p /mnt/seaweedfs
RUN mkdir -p /mnt/docker-volumes
RUN mkdir -p /run/docker/plugins

# Copy in package.json
COPY package.json /project/

# Switch to the project directory
WORKDIR /project

# Install project dependencies
RUN npm install

# Set Configuration Defaults
ENV HOST=localhost:8888 \
    ALIAS=seaweedfs \
    ROOT_VOLUME_NAME="" \
    MOUNT_OPTIONS="" \
    REMOTE_PATH=/.docker/volumes \
    LOCAL_PATH="" \
    CONNECT_TIMEOUT=10000 \
    LOG_LEVEL=info

# Copy in source code
COPY index.js /project

# Set the Docker entrypoint
ENTRYPOINT ["node", "index.js"]

####
# Install SeaweedFS Client
####

FROM build AS final
COPY --from=gasparekatapy/seaweedfs /usr/bin/weed /usr/bin/
RUN /usr/bin/weed version

FROM build AS final_large
COPY --from=gasparekatapy/seaweedfs:large /usr/bin/weed /usr/bin/
RUN /usr/bin/weed version