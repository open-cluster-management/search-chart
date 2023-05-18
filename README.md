<!-- Copyright Contributors to the Open Cluster Management project -->
# This project is deprecated.
- The functionality has been reimplemented in the new project https://github.com/stolostron/search-v2-operator
- The last RHACM release using this project is RHACM 2.6
- This project will be archived once RHACM 2.6 reaches end of life (EOL).

# search-chart
[Open Cluster Management](https://open-cluster-management.io/) - Helm chart for the search component.

### To install this chart

1. Log in to your cluster with the following command:

   ```bash
   oc login --server=https://api.<your-cluster-ip>:6443
   ```

2. Create an image pull secret with your artifactory credentials:

   ```bash
   oc create secret docker-registry -n open-cluster-management quay-secret --docker-server=quay.io \
   --docker-username=<quay.io user> \
   --docker-password=<quay.io token>
   ```
3. Clone this repo (`search-chart`) on your local machine. 

4. Package the chart with the following command:
   
   ```bash
   make build-local
   ```
   
5. Install the chart with the following command:
  
   ```bash
   helm upgrade --install search \
   --namespace open-cluster-management \
   --set global.pullSecret=quay-secret \
   stable/search-prod-2.2.0.tgz --tls
   ```
