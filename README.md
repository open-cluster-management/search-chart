# search-chart
Repository that holds search chart.

### To install this chart
1. Log into your cluster
  ```bash
  oc login --server=https://api.<your-cluster-ip>:6443
  ```

2. Create an image pull secret with your artifactory credentials
  ```bash
  oc create secret docker-registry -n open-cluster-management quay-secret --docker-server=quay.io \
  --docker-username=<quay.io user> \
  --docker-password=<quay.io token>
  ```
3. Clone this repo on your local machine.

4. Package the chart:
  ```bash
  make build-local
  ```
5. Install the chart
  ```bash
  helm upgrade --install search \
  --namespace open-cluster-management \
  --set global.pullSecret=quay-secret \
  stable/search-prod-2.2.0.tgz --tls
  ```
