###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2019. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
###############################################################################
SHELL = /bin/bash
STABLE_BUILD_DIR = repo/stable
CHART_NAME ?= stable/search-prod
VERSION := $(shell cat COMPONENT_VERSION)


-include $(shell curl -fso .build-harness -H "Authorization: token ${GITHUB_TOKEN}" -H "Accept: application/vnd.github.v3.raw" "https://raw.github.ibm.com/ICP-DevOps/build-harness/master/templates/Makefile.build-harness"; echo .build-harness)


default::
	@echo "Build Harness Bootstrapped"


init:
	curl -fksSL https://storage.googleapis.com/kubernetes-helm/helm-v2.14.1-linux-amd64.tar.gz | sudo tar --strip-components=1 -xvz -C /usr/local/bin/ linux-amd64/helm
	helm init -c

lint: setup
	@mkdir -p $(STABLE_BUILD_DIR)
	helm lint $(CHART_NAME)

build:
	@echo "CHART_NAME: $(CHART_NAME)"
	@echo "CHART_VERSION: $(VERSION)"
	helm package  --version $(VERSION) $(CHART_NAME)  -d $(STABLE_BUILD_DIR)

build-local: lint
	helm package  $(CHART_NAME) -d $(STABLE_BUILD_DIR)


