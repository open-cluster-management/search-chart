# search-chart
Helm chart to deploy search in an IBM Cloud Private cluster.

# Overview

This repository contains the MCM Search chart and related tooling for development, test, and release to the consolidated internal [IBMPrivateCloud/charts](https://github.ibm.com/IBMPrivateCloud/charts) repository and ultimately delivery to [IBM/Charts](https://github.com/IBM/charts) (if applicable).  On each branch push (or tag of commit), a travis build will be triggered to run cv lint and perform any installation (per cvt-tests/test-xx directory) / helm tests (per templates/tests).

* Travis build logs will be available here : https://travis.ibm.com/IBMPrivateCloud/search-chart
* A Helm-repo for testing will be created here : http://icpbuild.rtp.raleigh.ibm.com:31532/IBMPrivateCloud/search-chart/
* Reference templates for Storage, Database, etc. are available here : https://github.ibm.com/IBMPrivateCloud/charts/tree/master/samples

Note: See the IBM Cloud Private Content Provider Playbook [CI/CD PIPELINE](http://icp-content-playbook.rch.stglabs.ibm.com/building-content/developing-charts/cicd-pipeline/) section for further details on setting up travis builds, releasing charts, etc.

### Obtaining information and prepare for installation
- switch kubectl and helm config to **hub-cluster** with `cloudctl login`
```
export HUB_CLUSTER_IP=<IP-of-hub-cluster>

cloudctl login -a https://${HUB_CLUSTER_IP}:8443 --skip-ssl-validation
```
- during `cloudctl login` you will see output similar to this
```
Configuring kubectl ...
Property "clusters.mycluster" unset.
Property "users.mycluster-user" unset.
Property "contexts.mycluster-context" unset.
Cluster "mycluster" set.
User "mycluster-user" set.
Context "mycluster-context" created.
Switched to context "mycluster-context".
OK
```
`Cluster "mycluster" set.` line show the name of the cluster. In this case the cluster name is "mycluster"
`User "mycluster-user" set.` line shows the name of the user. In this case the user name is "mycluster-user"
- set the following variables according to above output
```
export HUB_CLUSTER_NAME=<name-of-the-cluster>
export HUB_CLUSTER_USER=<name-of-the-user>
```
- obtain Kubernete API Server URL <hub-cluster-url> for the **hub-cluster** from kubectl config
```
export HUB_CLUSTER_URL=`kubectl config view -o jsonpath="{.clusters[?(@.name==\"${HUB_CLUSTER_NAME}\")].cluster.server}"`
echo "HUB_CLUSTER_URL=${HUB_CLUSTER_URL}"
```
 - obtain Kubernete API Server token <hub-cluster-token> for the **hub-cluster** from kubectl config
```
export HUB_CLUSTER_TOKEN=`kubectl config view -o jsonpath="{.users[?(@.name==\"${HUB_CLUSTER_USER}\")].user.token}"`
echo "HUB_CLUSTER_TOKEN=${HUB_CLUSTER_TOKEN}"
```
- create Multicloud Manager namespace (default: mcm)
This namespace is the dedicated namespace use for assigning resources (such as compliance policy) to the Multicloud Manager controller.
```
export MCM_NAMESPACE=mcm

kubectl create namespace ${MCM_NAMESPACE}
```

## Standalone install of MCM Controller and Console on **hub-cluster** (managing-cluster)
- go into the helm chart repo directory
```
cd search-chart
```
- switch kubectl and helm config to **hub-cluster** with `cloudctl login`
```
cloudctl login -a https://${HUB_CLUSTER_IP}:8443 --skip-ssl-validation
```
- install mcm controller with helm chart
```
helm upgrade --install mcm-search \
--namespace kube-system \
--set global.pullSecret=my-docker-secret \
--set global.tillerIntegration.user=admin \
repo/stable/ibm-mcm-search-prod-99.99.99.tgz --tls
```
