###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2019. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
###############################################################################
SHELL = /bin/bash
STABLE_BUILD_DIR = repo/stable
CHART_NAME ?= stable/search-prod
VERSION := 3.5.0


.PHONY: default
default:: init;

.PHONY: init\:
init::

-include $(shell curl -fso .build-harness -H "Authorization: token ${GITHUB_TOKEN}" -H "Accept: application/vnd.github.v3.raw" "https://raw.github.ibm.com/ICP-DevOps/build-harness/master/templates/Makefile.build-harness"; echo .build-harness)


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

build-local: lint
	helm package  $(CHART_NAME) -d $(STABLE_BUILD_DIR)



local:
	for file in `find . -name values.yaml`; do echo $$file; sed -i '' -e "s|ibmcom|$(LOCAL_REPO)|g" $$file; done
	make build-local
	for file in `find . -name values.yaml`; do echo $$file; sed -i '' -e "s|$(LOCAL_REPO)|ibmcom|g" $$file; done

local-ppc:
	for file in `find . -name values.yaml`; do echo $$file; sed -i '' -e "s|ibmcom|$(LOCAL_REPO)|g" $$file; done
	for file in `find . -name values.yaml`; do echo $$file; sed -i '' -e "/repository/s/$$/-ppc64le/" $$file; done
	make build-local
	for file in `find . -name values.yaml`; do echo $$file; sed -i '' -e "s|$(LOCAL_REPO)|ibmcom|g" $$file; done
	for file in `find . -name values.yaml`; do echo $$file; sed -i '' -e "/repository/ s/-ppc64le//" $$file; done

local-s390x:
	for file in `find . -name values.yaml`; do echo $$file; sed -i '' -e "s|ibmcom|$(LOCAL_REPO)|g" $$file; done
	for file in `find . -name values.yaml`; do echo $$file; sed -i '' -e "/repository/s/$$/-s390x/" $$file; done
	make build-local
	for file in `find . -name values.yaml`; do echo $$file; sed -i '' -e "s|$(LOCAL_REPO)|ibmcom|g" $$file; done
	for file in `find . -name values.yaml`; do echo $$file; sed -i '' -e "/repository/ s/-s390x//" $$file; done
