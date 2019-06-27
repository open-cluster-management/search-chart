###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2019. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
###############################################################################
SHELL = /bin/bash
STABLE_BUILD_DIR = repo/stable
STABLE_REPO_URL ?= https://raw.githubusercontent.com/IBM/charts/master/repo/stable/
STABLE_CHARTS := $(wildcard stable/*)

# CHART_NAME?= stable/ibm-mcm-search
CHART_NAME ?= stable/search-chart
ARTIFACTORY_URL ?= https://na.artifactory.swg-devops.com/artifactory
ARTIFACTORY_REPO ?= hyc-cloud-private-integration-helm-local
LOCAL_REPO=hyc-cloud-private-integration-docker-local.artifactory.swg-devops.com/ibmcom

VERSION := $(shell grep version ./$(CHART_NAME)/Chart.yaml | awk '{print $$2}')

$(STABLE_BUILD_DIR):
	@mkdir -p $@

.PHONY: charts charts-stable $(STABLE_CHARTS)

# Default aliases: charts
charts: charts-stable

charts-stable: $(STABLE_CHARTS)
$(STABLE_CHARTS): $(STABLE_BUILD_DIR)
	helm package $@ -d $(STABLE_BUILD_DIR)

# Pushes chart to Artifactory repository.
release-chart: charts-stable
	$(eval VERSION_NUMBER ?= ${VERSION})
	$(eval NAME := $(notdir $(CHART_NAME)))
	$(eval FILE_NAME := $(NAME)-$(VERSION_NUMBER).tgz)
	$(eval URL := $(ARTIFACTORY_URL)/$(ARTIFACTORY_REPO))
	curl -H "X-JFrog-Art-Api: $(ARTIFACTORY_APIKEY)" -T $(STABLE_BUILD_DIR)/$(FILE_NAME) $(URL)/$(FILE_NAME)

local:
	for file in `find . -name values.yaml`; do echo $$file; sed -i '' -e "s|ibmcom|$(LOCAL_REPO)|g" $$file; done
	make charts
	for file in `find . -name values.yaml`; do echo $$file; sed -i '' -e "s|$(LOCAL_REPO)|ibmcom|g" $$file; done

local-ppc:
	for file in `find . -name values.yaml`; do echo $$file; sed -i '' -e "s|ibmcom|$(LOCAL_REPO)|g" $$file; done
	for file in `find . -name values.yaml`; do echo $$file; sed -i '' -e "/repository/s/$$/-ppc64le/" $$file; done
	make charts
	for file in `find . -name values.yaml`; do echo $$file; sed -i '' -e "s|$(LOCAL_REPO)|ibmcom|g" $$file; done
	for file in `find . -name values.yaml`; do echo $$file; sed -i '' -e "/repository/ s/-ppc64le//" $$file; done