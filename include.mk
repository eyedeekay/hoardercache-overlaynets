
export overlaynets-device-id = $(shell overlaynets -device-id 2>/dev/null)
export overlaynets-apikey = $(shell grep apikey $(HOME)/.config/overlaynets/config.xml | sed 's|apikey||g' | tr -d '</>' 2>/dev/null)

export docker-overlaynets-device-id = $(shell docker exec hoardercache-overlaynets overlaynets -device-id)
export docker-overlaynets-apikey = $(shell docker exec hoardercache-overlaynets grep apikey $(HOME)/.config/overlaynets/config.xml | sed 's|apikey||g' | tr -d '</>' )

export import_directory ?= $(working_directory)/hoardercache-overlaynets/import
export settings_directory ?= $(working_directory)/hoardercache-overlaynets/overlaynets

define I2P_TUNNELS_CONF
[aptcacher]
type = http
host = 127.0.0.1
port = 3142
keys = aptcacher.dat
inbound.length = 1
outbound.length = 1

[aptclient]
type = client
host = 127.0.0.1
port = 7142
keys = aptcacher.dat
inbound.length = 1
outbound.length = 1
endef

export I2P_TUNNELS_CONF

overlaynets-api:
	@echo "$(overlaynets-apikey)"

addon-overlaynets-build:
	docker build --force-rm -t hoardercache-overlaynets -f hoardercache-overlaynets/Dockerfile.i2p .

addon-overlaynets-run-daemon:
	docker run \
		-h apthoarder-overlaynets \
		-p 3142 \
		-p 7142 \
		--restart=always \
		--name hoardercache-overlaynets \
		-t hoardercache-overlaynets

addon-overlaynets-restart:
	docker rm -f hoardercache-overlaynets; \
	make addon-overlaynets-run-daemon

addon-overlaynets-clobber:
	docker rm -f hoardercache-overlaynets; \
	docker rmi -f hoardercache-overlaynets; \
	docker system prune -f

addon-overlaynets-pull:
	cd hoardercache-overlaynets; git pull

addon-overlaynets-update: addon-overlaynets-pull addon-overlaynets-build addon-overlaynets-restart

overlaynets-cacheconf:
	@echo "$$I2P_TUNNELS_CONF" | tee tunnels.conf

overlaynets-installcacheconf:
	install tunnels.conf /var/lib/i2pd/tunnels.conf
	chown i2pd:nobody /var/lib/i2pd/tunnels.conf

overlaynets-device-id:
	@echo $(docker-overlaynets-device-id)

overlaynets-web:
	surf http://127.0.0.1:43842/
