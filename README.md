# search-chart
Repository that holds search chart.

### To install this chart
1. Log into your cluster
  ```bash
  cloudctl login -a https://<your-cluster-ip>:8443
  ```

2. Create an image pull secret with your artifactory credentials
  ```bash
  kubectl create secret docker-registry -n kube-system  artifactory-secret --docker-server=hyc-cloud-private-integration-docker-local.artifactory.swg-devops.com \
  --docker-username=<youremail@us.ibm.com> \
  --docker-password=<ARTIFACTORY_TOKEN>
  ```
3. Clone this repo on your local machine.

4. Package the chart:
  ```bash
  make local
  ```
5. Install the chart
  ```bash
  helm upgrade --install search \
  --namespace kube-system \
  --set global.pullSecret=artifactory-secret \
  --set global.tillerIntegration.user=admin \
  repo/stable/search-99.99.99.tgz --tls
  ```