# 2021-01-13 18:35:25

FROM node:10-alpine as final

LABEL mantainer="Gaspare Iengo <gaspare@katapy.com>"
RUN \
  apk add --no-cache --update fuse3 fuse && \
  rm -rf /tmp/*

####
# Install Docker volume driver API server
####

# Create directories for mounts
RUN mkdir -p /mnt/seaweedfs
RUN mkdir -p /mnt/docker-volumes
RUN mkdir -p /run/docker/plugins

# Copy in package.json
COPY package.json package-lock.json /project/

# Switch to the project directory
WORKDIR /project

# Install project dependencies
RUN npm install

# Set Configuration Defaults
ENV HOST=mfsmaster \
    PORT=9421 \
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

COPY --from=gasparekatapy/seaweedfs /usr/bin/weed /usr/bin/

FROM final AS final_large
COPY --from=gasparekatapy/seaweedfs:large /usr/bin/weed /usr/bin/
