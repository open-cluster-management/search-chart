# IBM Multicloud Manager - Search 

## Introduction

The search service is part of IBM Multicloud Manager. It enables users to search and manage resources in kubernetes clusters across different clouds managed by IBM Multicloud Manager.

## Contents

 1. Chart Details
 2. Online user documentation
 3. System requirements
 4. Installation
 5. Copyright and trademark information

## Chart Details
This chart deploys IBM Multicloud Manager Search function on the hub-cluster.

_IBM Multicloud Manager Search_ is a REST API layer which provides search capabilities for IBM Multicloud Manager , which runs on the central management cluster. 

## Prerequisites
* Higher Release than IBM Cloud Private Release  3.2.0 

## Online user documentation

For the most up-to-date IBM Multicloud Manager user documentation, see [IBM Multicloud Manager](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/mcm/getting_started/introduction.html).


## Resources Required

For more information about system requirements for IBM Cloud Private, see [System requirements](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/supported_system_config/system_reqs.html).

 For IBM Multicloud Manager Search, you need at least the following values:
    CPU: 1 cores
    Memory: 2 GB

## Installing the Chart

For the recent installation documentation, see [IBM Multicloud Manager installation overview](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/mcm/installing/installing.html).

## Configuration
The following tables lists the global configurable parameters of the search chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.tillerIntegration.user` | Username to tls connect Tiller from Hub | admin |
| `global.pullSecret` | Secret of Docker Authentication|

## Limitations

* These charts cannot be deployed multiple times in the same kuberentes namespace.

## Copyright and trademark information

© Copyright IBM Corporation 2019

U.S. Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

IBM®, the IBM logo and ibm.com® are trademarks of International Business Machines Corp., registered in many jurisdictions worldwide. Other product and service names might be trademarks of IBM or other companies. A current list of IBM trademarks is available on the Web at "Copyright and trademark information" at www.ibm.com/legal/copytrade.shtml.
