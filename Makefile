GO=go

TARGETS := demo
FULL_BUILD := $(shell git rev-parse HEAD)
BUILD := $(shell git rev-parse --short HEAD)
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
VERSION := $(BRANCH)-$(BUILD)

REGISTRY_ADDRESS ?= registry.host.com:5000
REPO_USERNAME ?= demo
REPO_PASSWORD ?= demo
REPO_PROJECT ?= rdemo
IMAGE_NAME := pdemo
IMAGE_FULLNAME := $(REGISTRY_ADDRESS)/$(REPO_PROJECT)/$(IMAGE_NAME):$(VERSION)
BUILD_IMAGE :=  $(REGISTRY_ADDRESS)/golang:1.22

project=gitlab.host.com/pdemo
LDFLAGS += -X "$(project)/pkg/version.BuildTS=$(shell date -u '+%Y-%m-%d %I:%M:%S')"
LDFLAGS += -X "$(project)/pkg/version.GitHash=$(FULL_BUILD)"
LDFLAGS += -X "$(project)/pkg/version.Version=$(VERSION)"
LDFLAGS += -X "$(project)/pkg/version.GitBranch=$(BRANCH)"
CodeRoot=/go/src/$(project)

packages = $(shell go list ./...|grep -v /vendor/|grep -v /mock/)
test:
	$(GO) test ${packages}

build: $(TARGETS)
$(TARGETS):
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 $(GO) build -o $@.out -ldflags '$(LDFLAGS)' $(project)/cmd/$@ 

irepo:
	echo '${REPO_PASSWORD}'| docker login -u '${REPO_USERNAME}' --password-stdin ${REGISTRY_ADDRESS}

ibuild:
	$(call docker_env, make build)

itest:
	$(call docker_env, sleep 120 && make test)

image: ibuild
	docker build -t $(IMAGE_FULLNAME) .
	docker push $(IMAGE_FULLNAME)

.PHONY: test build irepo itest ibuild image

define docker_env
	docker run --rm \
		-v /mnt/work/app/go/pkg/mod:/go/pkg/mod \
		-v ${PWD}:${CodeRoot} \
		-w ${CodeRoot} \
		${BUILD_IMAGE} bash -c "$(1)"
endef
