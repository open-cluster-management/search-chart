# search-chart
Repository that holds search chart.

### To install this chart
1. Log into your cluster
  ```bash
  cloudctl login -a https://<your-cluster-ip>:443
  ```

2. Create an image pull secret with your artifactory credentials
  ```bash
  kubectl create secret docker-registry -n kube-system quay-secret --docker-server=quay.io \
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
  --namespace kube-system \
  --set global.pullSecret=quay-secret \
  repo/stable/search-prod-3.5.0.tgz --tls
  ```
