# search-chart
Repository that holds search chart

### To install this chart

1. Create an image pull secret with your artifactory credentials
  ```bash
  kubectl create secret docker-registry -n kube-system  artifactory-secret --docker-server=hyc-cloud-private-integration-docker-local.artifactory.swg-devops.com \
  --docker-username=<youremail@us.ibm.com> \
  --docker-password=<ARTIFACTORY_TOKEN>
  ```
2. Package the chart:
  ```bash
  make local
  ```
3. Install the chart
  ```bash
  helm upgrade --install search \
  --set global.pullSecret=artifactory-secret \
  --set global.tillerIntegration.user=admin \
  repo/stable/search-99.99.99.tgz --tls
  ```