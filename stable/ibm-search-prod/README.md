# IBM Multicloud Manager - Search 

## Introduction

The Search service is part of the IBM Multicloud Manager. Search enables you to search for and manage resources in Kubernetes clusters across different clouds.

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

This chart deploys the IBM Multicloud Manager Search service on the hub cluster.

_IBM Multicloud Manager Search_ is a REST API layer that provides the Search service, which runs on the central management cluster. 

## Prerequisites

* RH OpenShift (4.2) OR
* IBM Cloud Pak for Multicloud Management

## Online user documentation

For the most up-to-date IBM Multicloud Manager user documentation, see [IBM Multicloud Manager](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/mcm/getting_started/introduction.html).

## PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the ICP management console. Note that this PodSecurityPolicy is already defined in IBM Cloud Private 3.1.1 or higher.

- From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy into the create resource section
  - Custom PodSecurityPolicy definition:
    ```
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      annotations:
        kubernetes.io/description: "This policy is the most restrictive,
          requiring pods to run with a non-root UID, and preventing pods from accessing the host."
        apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default
        apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default
        seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
        seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
      name: ibm-restricted-psp
    spec:
      allowPrivilegeEscalation: false
      forbiddenSysctls:
      - '*'
      fsGroup:
        ranges:
        - max: 65535
          min: 1
        rule: MustRunAs
      requiredDropCapabilities:
      - ALL
      runAsUser:
        rule: MustRunAsNonRoot
      seLinux:
        rule: RunAsAny
      supplementalGroups:
        ranges:
        - max: 65535
          min: 1
        rule: MustRunAs
      volumes:
      - configMap
      - emptyDir
      - secret
    ```
  - Custom ClusterRole for the custom PodSecurityPolicy:
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: ibm-restricted-psp-clusterrole
    rules:
    - apiGroups:
      - extensions
      resourceNames:
      - ibm-restricted-psp
      resources:
      - podsecuritypolicies
      verbs:
      - use
    ```

# Red Hat OpenShift SecurityContextConstraints Requirements
Supports Red Hat OpenShift SecurityContextConstraints [`ibm-anyuid-scc`](https://ibm.biz/cpkspec-scc)

## Resources Required

For IBM Multicloud Manager Search, minimum resource requirements in the cluster is as follows:
    CPU: 1 core
    Memory: 2 GB

## Installing the Chart

For the recent installation documentation, see [IBM Multicloud Manager installation overview](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/mcm/installing/installing.html).

## Configuration

1. Enter `search` (lower case) as the release name so that you can use IBM Multicloud Manager management console.

2. Choose the `kube-system` namespace, which contains your IBM Multicloud Manager resources.

3. Choose the target cluster that has `multi-cluster hub` configured.

The following tables lists the global configurable parameters of the search chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.tillerIntegration.user` | Username to tls connect Tiller from hub cluster | admin |
| `global.pullSecret` | Secret of Docker Authentication|

## Limitations

* These charts cannot be deployed multiple times in the same Kuberentes namespace.

## Copyright and trademark information

© Copyright IBM Corporation 2019

U.S. Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

IBM®, the IBM logo and ibm.com® are trademarks of International Business Machines Corp., registered in many jurisdictions worldwide. Other product and service names might be trademarks of IBM or other companies. A current list of IBM trademarks is available on the Web at "Copyright and trademark information" at www.ibm.com/legal/copytrade.shtml.
