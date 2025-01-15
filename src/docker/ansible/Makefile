# Default Target
.DEFAULT_GOAL := help

.PHONY: help all build_ansible_latest build_ansible_8 build_ansible_10 build_ansible_latest_debian build_ansible_8_debian build_ansible_10_debian

# Help target to list available commands
help:
	@echo "Available targets:"
	@echo "  help                        - Display this help"
	@echo "  all                         - Build all Ansible Alpine Docker images"
	@echo "  all_debian                  - Build all Ansible Debian Docker images"
	@echo "  build_ansible_latest        - Build the Ansible latest Alpine Docker image"
	@echo "  build_ansible_8             - Build the Ansible 8 Alpine Docker image"
	@echo "  build_ansible_10            - Build the Ansible 10 Alpine Docker image"
	@echo "  build_ansible_latest_debian - Build the Ansible latest Debian Docker image"
	@echo "  build_ansible_8_debian      - Build the Ansible 8 Debian Docker image"
	@echo "  build_ansible_10_debian     - Build the Ansible 10 Debian Docker image"

# Targets
all: build_ansible_latest build_ansible_8 build_ansible_10
all_debian: build_ansible_latest_debian build_ansible_8_debian build_ansible_10_debian

# Build Ansible latest target
build_ansible_latest: Dockerfile.alpine
	@echo "Start building Alpine Docker image for Ansible latest..."
	@docker buildx build --load --progress=plain --file Dockerfile.alpine --tag local/ansible:latest-alpine --build-arg ANSIBLE_VERSION=latest .

# Build Ansible 8 target
build_ansible_8: Dockerfile.alpine
	@echo "Start building Alpine Docker image for Ansible 8..."
	@docker buildx build --load --progress=plain --file Dockerfile.alpine --tag local/ansible:8-alpine --build-arg ANSIBLE_VERSION=8 .

# Build Ansible 10 target
build_ansible_10: Dockerfile.alpine
	@echo "Start building Alpine Docker image for Ansible 10..."
	@docker buildx build --load --progress=plain --file Dockerfile.alpine --tag local/ansible:10-alpine --build-arg ANSIBLE_VERSION=10 .

# Build Ansible latest target
build_ansible_latest_debian: Dockerfile.debian
	@echo "Start building Debian Docker image for Ansible latest..."
	@docker buildx build --load --progress=plain --file Dockerfile.debian --tag local/ansible:latest-debian --build-arg ANSIBLE_VERSION=latest .

# Build Ansible 8 target
build_ansible_8_debian: Dockerfile.debian
	@echo "Start building Debian Docker image for Ansible 8..."
	@docker buildx build --load --progress=plain --file Dockerfile.debian --tag local/ansible:8-debian --build-arg ANSIBLE_VERSION=8 .

# Build Ansible 10 target
build_ansible_10_debian: Dockerfile.debian
	@echo "Start building Debian Docker image for Ansible 10..."
	@docker buildx build --load --progress=plain --file Dockerfile.debian --tag local/ansible:10-debian --build-arg ANSIBLE_VERSION=10 .
