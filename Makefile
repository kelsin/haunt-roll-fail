.PHONY: build run shell
image = hrf:local
run = run -it --rm
host = localhost
port = 7070
url = http://$(host):$(port)

all: build run

build:
	@docker build --build-arg URL=$(url) -t $(image) .

run: build
	@docker $(run) --name hrf -v hrf-db:/db -p $(port):7070 $(image)

shell: build
	@docker $(run) --name hrf-shell $(image) bash

assets-list:
	@tar -tzf assets.tar.gz

assets-unpack:
	@tar -xzf assets.tar.gz

assets-build:
	@tar -czf assets.tar.gz assets
