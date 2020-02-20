# Multicloud Search 

## Introduction

The Multicloud Search service enables you to search for and manage resources in Kubernetes clusters across different clouds.

## Contents

 1. Chart Details
 2. Prerequisites
 2. Online user documentation
 3. System requirements
 4. Installation
 5. Configuration
 6. Limitations
 5. Copyright and trademark information

## Chart Details

This chart deploys the Multicloud Search service on the hub cluster.

_Multicloud Search_ is a REST API layer that provides the Search service, which runs on the central management cluster. 

## Prerequisites

* RH OpenShift (4.2) 

## Online user documentation


## PodSecurityPolicy Requirements
   This chart has to be installed in kube-system namespace.
# Red Hat OpenShift SecurityContextConstraints Requirements
   This chart has to be installed in  kube-system namespace on a OpenShift cluster.
## Resources Required

For Multicloud Search, minimum resource requirements in the cluster is as follows:
    CPU: 1 core
    Memory: 2 GB

## Installing the Chart


## Configuration

1. Enter `search` (lower case) as the release name so that you can use the management console.

2. Choose the `kube-system` namespace.


The following tables lists the global configurable parameters of the search chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.tillerIntegration.user` | Username to tls connect Tiller from hub cluster | admin |
| `global.pullSecret` | Secret for Docker authentication|

## Limitations

* These charts cannot be deployed multiple times in the same Kuberentes namespace.
