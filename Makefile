
include Configfile

CHART_NAME ?= mcm-search-chart
VERSION ?= $(shell grep version ./$(CHART_NAME)/Chart.yaml | awk '{print $$2}')
FILENAME ?= ${CHART_NAME}-${VERSION}.tgz

.PHONY: build lint setup

default: build

tool:
	curl -fksSL https://storage.googleapis.com/kubernetes-helm/helm-v2.7.2-linux-amd64.tar.gz | sudo tar --strip-components=1 -xvz -C /usr/local/bin/ linux-amd64/helm

setup:
	helm init -c

lint: setup
	helm lint $(CHART_NAME)

build: lint
	helm package $(CHART_NAME)

publish: build
	# We need to get the tar file, does it exist
	@echo "Version: ${VERSION}"
	if [ ! -f ./$(FILENAME) ]; then \
    echo "File not found! - exitin"; \
		exit; \
	fi

	# And push it to artifactory
	curl -u $(ARTIFACTORY_USERNAME):$(ARTIFACTORY_APIKEY) -T $(FILENAME) "https://na.artifactory.swg-devops.com/artifactory/$(HELM_REPO_NAME)/$(FILENAME)"
	@echo "DONE"

include Makefile.docker