IMAGE_NAME ?= win32-srcds
PORTS      ?= -p 27015:27015/udp -p 27015:27015/tcp -p 8080:8080

UNAME_M := $(shell uname -m)
ifeq ($(UNAME_M),x86_64)
ARCH := x64
else ifeq ($(UNAME_M),amd64)
ARCH := x64
else ifeq ($(UNAME_M),aarch64)
ARCH := arm64
else ifeq ($(UNAME_M),arm64)
ARCH := arm64
else
$(error Unsupported host architecture: $(UNAME_M). Use make run-x64 or make run-arm64.)
endif

.PHONY: build build-x64 build-arm64 run run-x64 run-arm64

build: build-$(ARCH)

run: run-$(ARCH)

build-x64:
	docker build -f Dockerfile.x64 -t $(IMAGE_NAME):x64 .

build-arm64:
	docker build -f Dockerfile.arm64 -t $(IMAGE_NAME):arm64 .

run-x64: build-x64
	docker run --rm -it $(PORTS) $(IMAGE_NAME):x64

run-arm64: build-arm64
	docker run --rm -it $(PORTS) $(IMAGE_NAME):arm64
