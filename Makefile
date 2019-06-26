###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2017. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation - initial API and implementation
###############################################################################
SHELL = /bin/bash
STABLE_BUILD_DIR = repo/stable
STABLE_REPO_URL ?= https://raw.githubusercontent.com/IBM/charts/master/repo/stable/
STABLE_CHARTS := $(wildcard stable/*)
STABLE_CHARTS_DIR="stable"

STAGING="daily"
DATE=$(shell date +%F)
CHART_NAME?= stable/ibm-mcm-search-prod
ARTIFACTORY_URL ?= https://na.artifactory.swg-devops.com/artifactory
ARTIFACTORY_REPO ?= hyc-cloud-private-integration-helm-local
LOCAL_REPO=hyc-cloud-private-integration-docker-local.artifactory.swg-devops.com/ibmcom

VERSION := $(shell grep version ./$(CHART_NAME)/Chart.yaml | awk '{print $$2}')

.DEFAULT_GOAL=all

$(STABLE_BUILD_DIR):
	@mkdir -p $@

.PHONY: charts charts-stable $(STABLE_CHARTS)

# Default aliases: charts, repo

charts: charts-stable

repo: repo-stable

charts-stable: $(STABLE_CHARTS)
$(STABLE_CHARTS): $(STABLE_BUILD_DIR)
	#cv lint $@
	helm package $@ -d $(STABLE_BUILD_DIR)

.PHONY: repo repo-stable repo-incubating

repo-stable: $(STABLE_CHARTS) $(STABLE_BUILD_DIR)
	helm repo index $(STABLE_BUILD_DIR) --url $(STABLE_REPO_URL)

.PHONY: all
all: repo-stable
	cv lint --overrides=./$(CHART_NAME)/cv-tests/lintOverrides.yaml  --namespace="kube-system" $(STABLE_CHARTS)

package-chart-mcm-for-ppa:
	./scripts/packageChartsforPPA.sh $(STABLE_BUILD_DIR) $(STABLE_CHARTS_DIR)

ppa:   package-chart-mcm-for-ppa
	sed -i -e "s|{{ ARTIFACTORY_USERNAME }}|$(ARTIFACTORY_USERNAME)|g"  `pwd`/ppa-specs/mcm-3.2.yaml;
	sed -i -e "s|{{ ARTIFACTORY_TOKEN }}|$(ARTIFACTORY_TOKEN)|g"  `pwd`/ppa-specs/mcm-3.2.yaml;
	CLOUDCTL_TRACE=true ./cloudctl catalog create-archive --archive ./mcm-$(VERSION).tgz -s `pwd`/ppa-specs/mcm-3.2.yaml
#	./cloudctl catalog create-archive  --archive ./mcm-$(VERSION)-amd64.tgz -s ./stable/ibm-mcm-search-prod/ppa-specs/ibm-mcm-search-amd64.yaml
#	./cloudctl catalog create-archive  --archive ./mcm-$(VERSION)-ppc64le.tgz -s ./stable/ibm-mcm-search-prod/ppa-specs/ibm-mcm-search-ppc64le.yaml

ppa-local:  package-chart-mcm-for-ppa
	./cloudctl catalog create-archive --archive ./mcm-$(VERSION).tgz -s `pwd`/ppa-specs/mcm-3.2.yaml
#	./cloudctl catalog create-archive --archive ./mcm-$(VERSION)-amd64.tgz -s ./stable/ibm-mcm-search-prod/ppa-specs/ibm-mcm-search-amd64.yaml
#	./cloudctl catalog create-archive --archive ./mcm-$(VERSION)-ppc64le.tgz -s ./stable/ibm-mcm-search-prod/ppa-specs/ibm-mcm-search-ppc64le.yaml

uploadToArtifactory:
	mkdir mcm-$(VERSION)
	curl -H 'X-JFrog-Art-Api:$(ARTIFACTORY_APIKEY)' -T ./mcm-$(VERSION).tgz "https://na.artifactory.swg-devops.com/artifactory/hyc-mcm-$(STAGING)-generic-local/mcm-$(BRANCH)/mcm-$(DATE)/mcm-$(VERSION).tgz"

cv-lint:
	./cv lint --cv-tests-off --overrides=./$(CHART_NAME)/lintOverrides.yaml ./$(CHART_NAME)

# Pushes chart to Artifactory repository.
release-chart: charts-stable
	$(eval VERSION_NUMBER ?= ${VERSION})
	$(eval NAME := $(notdir $(CHART_NAME)))
	$(eval FILE_NAME := $(NAME)-$(VERSION_NUMBER).tgz)
	$(eval URL := $(ARTIFACTORY_URL)/$(ARTIFACTORY_REPO))
	curl -H "X-JFrog-Art-Api: $(ARTIFACTORY_APIKEY)" -T $(STABLE_BUILD_DIR)/$(FILE_NAME) $(URL)/$(FILE_NAME)


LOCAL_REPO=hyc-cloud-private-integration-docker-local.artifactory.swg-devops.com/ibmcom
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
