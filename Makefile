###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2019. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
###############################################################################
# Copyright (c) 2020 Red Hat, Inc.

SHELL = /bin/bash
STABLE_BUILD_DIR = stable
CHART_NAME ?= stable/search-prod
VERSION := $(shell cat COMPONENT_VERSION)

init:
	curl -fksSL https://storage.googleapis.com/kubernetes-helm/helm-v2.14.1-linux-amd64.tar.gz | sudo tar --strip-components=1 -xvz -C /usr/local/bin/ linux-amd64/helm
	helm init -c

lint:
	@mkdir -p $(STABLE_BUILD_DIR)
	helm lint $(CHART_NAME)

build:
	@echo "CHART_NAME: $(CHART_NAME)"
	@echo "CHART_VERSION: $(VERSION)"
	helm package  --version $(VERSION) $(CHART_NAME)  -d $(STABLE_BUILD_DIR)

build-local: lint
	helm package  $(CHART_NAME) -d $(STABLE_BUILD_DIR)

test:
	helm install search stable/search-prod --dry-run

copyright-check:
	./copyright-check.sh	
