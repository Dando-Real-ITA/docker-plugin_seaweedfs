PLUGIN_NAME = gasparekatapy/seaweedfs_plugin

all: clean rootfs create

clean:
	@echo "### rm ./plugin"
	@rm -rf ./plugin
	@echo "### rm ./plugin-large"
	@rm -rf ./plugin-large

config:
	@echo "### copy config.json to ./plugin/"
	@mkdir -p ./plugin
	@cp config.json ./plugin/
	@echo "### copy config.json to ./plugin-large/"
	@mkdir -p ./plugin-large
	@cp config.json ./plugin-large/

rootfs: config
	@echo "### docker build: rootfs image with"
	@DOCKER_BUILDKIT=1 docker build \
		--target final \
		-t ${PLUGIN_NAME}:rootfs \
		.
	@echo "### docker build: rootfs-large image with"
	@DOCKER_BUILDKIT=1 docker build \
		--target final_large \
		-t ${PLUGIN_NAME}:rootfs-large \
		.
	@echo "### create rootfs directory in ./plugin/rootfs"
	@mkdir -p ./plugin/rootfs
	@docker create --name tmp ${PLUGIN_NAME}:rootfs
	@docker export tmp | tar -x -C ./plugin/rootfs
	@docker rm -vf tmp
	@echo "### create rootfs directory in ./plugin-large/rootfs"
	@mkdir -p ./plugin-large/rootfs
	@docker create --name tmp-large ${PLUGIN_NAME}:rootfs-large
	@docker export tmp-large | tar -x -C ./plugin-large/rootfs
	@docker rm -vf tmp-large

create:
	@echo "### remove existing plugin ${PLUGIN_NAME} if exists"
	@docker plugin rm -f ${PLUGIN_NAME}:latest || true
	@docker plugin rm -f ${PLUGIN_NAME}:large || true
	@echo "### create new plugin ${PLUGIN_NAME}:latest from ./plugin"
	@docker plugin create ${PLUGIN_NAME}:latest ./plugin
	@echo "### create new plugin ${PLUGIN_NAME}:large from ./plugin-large"
	@docker plugin create ${PLUGIN_NAME}:large ./plugin-large

enable:
	@echo "### enable plugin ${PLUGIN_NAME}"
	@docker plugin enable ${PLUGIN_NAME}:latest
	@docker plugin enable ${PLUGIN_NAME}:large

disable:
	@echo "### disable plugin ${PLUGIN_NAME}"
	@docker plugin disable ${PLUGIN_NAME}:latest
	@docker plugin disable ${PLUGIN_NAME}:large

push:  clean rootfs create
	@echo "### push plugin ${PLUGIN_NAME}"
	@docker plugin push ${PLUGIN_NAME}:latest
	@docker plugin push ${PLUGIN_NAME}:large
