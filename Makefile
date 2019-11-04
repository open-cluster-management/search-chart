###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2019. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
###############################################################################
SHELL = /bin/bash
STABLE_BUILD_DIR = repo/stable

CHART_NAME ?= stable/ibm-search-prod
ARTIFACTORY_URL ?= https://na.artifactory.swg-devops.com/artifactory
ARTIFACTORY_SCRATCH_REPO ?= hyc-cloud-private-scratch-helm-local
ARTIFACTORY_INTEGRATION_REPO ?= hyc-cloud-private-integration-helm-local
LOCAL_REPO=hyc-cloud-private-integration-docker-local.artifactory.swg-devops.com/ibmcom

# GITHUB_USER containing '@' char must be escaped with '%40'
GITHUB_USER := $(shell echo $(GITHUB_USER) | sed 's/@/%40/g')
GITHUB_TOKEN ?=

.PHONY: default
default:: init;

.PHONY: init\:
init::
ifndef GITHUB_USER
	$(info GITHUB_USER not defined)
	exit 1
endif
	$(info Using GITHUB_USER=$(GITHUB_USER))
ifndef GITHUB_TOKEN
	$(info GITHUB_TOKEN not defined)
	exit 1
endif

-include $(shell curl -fso .build-harness -H "Authorization: token ${GITHUB_TOKEN}" -H "Accept: application/vnd.github.v3.raw" "https://raw.github.ibm.com/ICP-DevOps/build-harness/master/templates/Makefile.build-harness"; echo .build-harness)


VERSION := $(SEMVERSION)
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
	@echo "CHART_NAME: $(CHART_NAME)"
	@echo "CHART_VERSION: $(VERSION)"
	helm package  --version $(VERSION) $(CHART_NAME)  -d $(STABLE_BUILD_DIR)

push: build
	# We need to get the tar file, does it exist
	@echo "Version: ${VERSION}"
	if [ ! -f ./$(STABLE_BUILD_DIR)/$(FILE_NAME) ]; then \
    echo "File not found! - exiting"; \
		exit; \
	fi

	# And push it to scratch artifactory
	curl -H "X-JFrog-Art-Api: $(DOCKER_PASS)" -T $(STABLE_BUILD_DIR)/$(FILE_NAME) $(ARTIFACTORY_URL)/$(ARTIFACTORY_SCRATCH_REPO)/$(FILE_NAME)
	@echo "DONE"

publish: build
	# We need to get the tar file, does it exist
	@echo "Version: ${VERSION}"
	if [ ! -f ./$(STABLE_BUILD_DIR)/$(FILE_NAME) ]; then \
    echo "File not found! - exiting"; \
		exit; \
	fi

	# And push it to Integration artifactory
	curl -H "X-JFrog-Art-Api: $(DOCKER_PASS)" -T $(STABLE_BUILD_DIR)/$(FILE_NAME) $(ARTIFACTORY_URL)/$(ARTIFACTORY_INTEGRATION_REPO)/$(FILE_NAME)
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
