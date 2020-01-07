#!/bin/bash
#
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corporation 2019. All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
# runTests script REQUIRED ONLY IF additional application verification is
# needed above and beyond helm tests.
#
# Parameters :
#   -c <chartReleaseName>, the name of the release used to install the helm chart
#
# Pre-req environment: authenticated to cluster, kubectl cli install / setup complete, & chart installed

# Exit when failures occur (including unset variables)
set -o errexit
set -o nounset
set -o pipefail


# Process parameters notify of any unexpected
while test $# -gt 0; do
        [[ $1 =~ ^-r|--releaseName$ ]] && { releaseName="$2"; shift 2; continue; };
    echo "Parameter not recognized: $1, ignored"
    shift
done
: "${releaseName:="search"}"

# Parameters
# Below is the current set of parameters which are passed in to the app test script.
# The script can process or ignore the parameters
# The script can be coded to expect the parameter list below, but should not be coded such that additional parameters
# will cause the script to fail
#   -e <environment>, IP address of the environment
#   -r <release>, ie V.R.M.F-tag, the release notation associated with the environment, this will be V.R.M.F, plus an option -tag
#   -a <architecture>, the architecture of the environment
#   -u <userid>, the admin user id for the environment
#   -p <password>, the password for accessing the environment, base64 encoded, p=`echo p_enc | base64 -d` to decode the password when using


# Verify pre-req environment
command -v kubectl > /dev/null 2>&1 || { echo "kubectl pre-req is missing."; exit 1; }

# Setup and execute application test on installation
echo "Running application test on release $releaseName"
# Get Search-aggregator service port
NODE_PORT=$(kubectl get service -n kube-system $releaseName-search-aggregator | awk '{split($0, a, " "); print a[5]}' | awk '{split($0, a, "/"); print a[1]}' | sed -n '2 p')

number_regex='^[0-9]+$'
if ! [[ $NODE_PORT =~ $number_regex ]] ; then
   echo "Error: Not a port number" ; exit 1
fi

# Do a port forward to access the servive
echo "executing  kubectl port-forward svc/${releaseName}-search-aggregator 6666:$NODE_PORT &"
(kubectl port-forward svc/${releaseName}-search-aggregator 6666:$NODE_PORT &)
pfwd_pid=$(ps -ef | grep '6666:' | grep -v 'grep' |awk '{ printf $2 }')
sleep 5
output=$(curl -k https://localhost:6666/liveness)
echo "NODE PORT $output"
#Check if the service is live
if ! [[ $output =~ "OK" ]] ; then
   echo "Error: Service Not running" ; (kill -9 $pfwd_pid);exit 1
fi

(kill -9 $pfwd_pid)
echo "Application Test Sucessful" 
exit 0
