###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2019. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
###############################################################################
SHELL = /bin/bash
STABLE_BUILD_DIR = repo/stable

CHART_NAME ?= stable/search
ARTIFACTORY_URL ?= https://na.artifactory.swg-devops.com/artifactory
ARTIFACTORY_SCRATCH_REPO ?= hyc-cloud-private-scratch-helm-local
ARTIFACTORY_INTEGRATION_REPO ?= hyc-cloud-private-integration-helm-local
LOCAL_REPO=hyc-cloud-private-integration-docker-local.artifactory.swg-devops.com/ibmcom

VERSION := $(shell grep version ./$(CHART_NAME)/Chart.yaml | awk '{print $$2}')
$(eval VERSION_NUMBER ?= ${VERSION})
$(eval NAME := $(notdir $(CHART_NAME)))
$(eval FILE_NAME := $(NAME)-$(VERSION_NUMBER).tgz)

$(STABLE_BUILD_DIR):
	@mkdir -p $@

tool:
	curl -fksSL https://storage.googleapis.com/kubernetes-helm/helm-v2.12.3-linux-amd64.tar.gz | sudo tar --strip-components=1 -xvz -C /usr/local/bin/ linux-amd64/helm

setup:
	helm init -c

lint: setup
	@mkdir -p $(STABLE_BUILD_DIR)
	helm lint $(CHART_NAME)

build: lint
	helm package $(CHART_NAME)  -d $(STABLE_BUILD_DIR)

push: build
	# We need to get the tar file, does it exist
	@echo "Version: ${VERSION}"
	if [ ! -f ./$(STABLE_BUILD_DIR)/$(FILE_NAME) ]; then \
    echo "File not found! - exiting"; \
		exit; \
	fi

	# And push it to scratch artifactory
	curl -H "X-JFrog-Art-Api: $(ARTIFACTORY_TOKEN)" -T $(STABLE_BUILD_DIR)/$(FILE_NAME) $(ARTIFACTORY_URL)/$(ARTIFACTORY_SCRATCH_REPO)/$(FILE_NAME)
	@echo "DONE"

publish: build
	# We need to get the tar file, does it exist
	@echo "Version: ${VERSION}"
	if [ ! -f ./$(STABLE_BUILD_DIR)/$(FILE_NAME) ]; then \
    echo "File not found! - exiting"; \
		exit; \
	fi

	# And push it to Integration artifactory
	curl -H "X-JFrog-Art-Api: $(ARTIFACTORY_TOKEN)" -T $(STABLE_BUILD_DIR)/$(FILE_NAME) $(ARTIFACTORY_URL)/$(ARTIFACTORY_INTEGRATION_REPO)/$(FILE_NAME)
	@echo "DONE"

local:
	for file in `find . -name values.yaml`; do echo $$file; sed -i '' -e "s|ibmcom|$(LOCAL_REPO)|g" $$file; done
	make build
	for file in `find . -name values.yaml`; do echo $$file; sed -i '' -e "s|$(LOCAL_REPO)|ibmcom|g" $$file; done

local-ppc:
	for file in `find . -name values.yaml`; do echo $$file; sed -i '' -e "s|ibmcom|$(LOCAL_REPO)|g" $$file; done
	for file in `find . -name values.yaml`; do echo $$file; sed -i '' -e "/repository/s/$$/-ppc64le/" $$file; done
	make build
	for file in `find . -name values.yaml`; do echo $$file; sed -i '' -e "s|$(LOCAL_REPO)|ibmcom|g" $$file; done
	for file in `find . -name values.yaml`; do echo $$file; sed -i '' -e "/repository/ s/-ppc64le//" $$file; done

local-s390x:
	for file in `find . -name values.yaml`; do echo $$file; sed -i '' -e "s|ibmcom|$(LOCAL_REPO)|g" $$file; done
	for file in `find . -name values.yaml`; do echo $$file; sed -i '' -e "/repository/s/$$/-s390x/" $$file; done
	make build
	for file in `find . -name values.yaml`; do echo $$file; sed -i '' -e "s|$(LOCAL_REPO)|ibmcom|g" $$file; done
	for file in `find . -name values.yaml`; do echo $$file; sed -i '' -e "/repository/ s/-s390x//" $$file; done