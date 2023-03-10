CONTAINER_RUNTIME ?= docker
CONTAINER_IMAGE := "ghcr.io/kubewarden/swift-wasm-runner:5.3-p1"
VERSION := $(shell git describe --exact-match --tags $(git log -n1 --pretty='%h') | cut -c2-)

build:
ifndef CONTAINER_RUNTIME
	@printf "Please install either docker or podman"
	exit 1
endif
	$(CONTAINER_RUNTIME) run --rm -v $(PWD):/code --entrypoint /bin/bash $(CONTAINER_IMAGE) -c "cd /code && swift build --triple wasm32-unknown-wasi"

shell:
ifndef CONTAINER_RUNTIME
	@printf "Please install either docker or podman"
	exit 1
endif
	$(CONTAINER_RUNTIME) run --rm -ti -v $(PWD):/code --entrypoint /bin/bash $(CONTAINER_IMAGE)

test:
ifndef CONTAINER_RUNTIME
	@printf "Please install either docker or podman"
	exit 1
endif
	$(CONTAINER_RUNTIME) run --rm -v $(PWD):/code --entrypoint /bin/bash $(CONTAINER_IMAGE) -c "cd /code && carton test"

clean:
	sudo rm -rf .build
	rm -rf *.wasm

release:
ifndef CONTAINER_RUNTIME
	@printf "Please install either docker or podman"
	exit 1
endif
	@printf "Build WebAssembly module"
	$(CONTAINER_RUNTIME) run --rm -v $(PWD):/code --entrypoint /bin/bash $(CONTAINER_IMAGE) -c "cd /code && swift build -c release --triple wasm32-unknown-wasi"

	@printf "Strip Wasm binary\n"
	sudo chmod 777 .build/wasm32-unknown-wasi/release/Policy.wasm
	wasm-strip .build/wasm32-unknown-wasi/release/Policy.wasm

	@printf "Optimize Wasm binary, hold on...\n"
	wasm-opt -Os .build/wasm32-unknown-wasi/release/Policy.wasm -o policy.wasm

artifacthub-pkg.yml: metadata.yml
	kwctl scaffold artifacthub \
	    --metadata-path metadata.yml --version $(VERSION) \
		--questions-path questions-ui.yml > artifacthub-pkg.yml.tmp \
	&& mv artifacthub-pkg.yml.tmp artifacthub-pkg.yml \
	|| rm -f artifacthub-pkg.yml.tmp

annotate:
	kwctl annotate -m metadata.yml -u README.md -o annotated-policy.wasm policy.wasm

e2e-tests:
	bats e2e.bats
