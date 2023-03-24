CONTAINER_RUNTIME ?= docker
CONTAINER_IMAGE := "ghcr.io/kubewarden/swift-wasm-runner:5.3-p1"
# It's necessary to call cut because kwctl command does not handle version
# starting with v.
VERSION ?= $(shell git describe | cut -c2-)

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

artifacthub-pkg.yml: metadata.yml go.mod
	$(warning If you are updating the artifacthub-pkg.yml file for a release, \
	  remember to set the VERSION variable with the proper value. \
	  To use the latest tag, use the following command:  \
	  make VERSION=$$(git describe --tags --abbrev=0 | cut -c2-) annotated-policy.wasm)
	kwctl scaffold artifacthub \
	  --metadata-path metadata.yml --version $(VERSION) \
	  --output artifacthub-pkg.yml


annotate: artifacthub-pkg.yml
	kwctl annotate -m metadata.yml -u README.md -o annotated-policy.wasm policy.wasm

e2e-tests:
	bats e2e.bats
