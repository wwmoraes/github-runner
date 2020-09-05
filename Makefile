IMAGE_NAME := wwmoraes/github-runner

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

build: BUILD_DATE=$(shell date -u '+%FT%TZ')
build: SOURCE_COMMIT=$(shell git rev-parse HEAD)
build: VERSION=$(shell git describe --tags || echo v0.0.0)
build: ## Build the image
	@docker build \
		--build-arg BUILD_DATE="$(BUILD_DATE)" \
		--build-arg SOURCE_COMMIT="$(SOURCE_COMMIT)" \
		--build-arg VERSION="$(VERSION)" \
		-t $(IMAGE_NAME) docker

shell: ## Creates a shell inside the container for debug purposes
	@docker run -it --env-file .env --entrypoint=bash $(IMAGE_NAME)

shell-compose: ## Creates a shell inside the docker-compose service for debug purposes
	@docker-compose run --rm --entrypoint /bin/bash runner
