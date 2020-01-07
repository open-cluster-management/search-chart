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

#A wait to ensure all pods have come up
sleep 100

# Setup and execute application test on installation
echo "Running install verification test on release $releaseName"
# Get search pod count 
POD_COUNT=$(kubectl get pods -n kube-system | grep ^${releaseName}-  | awk '{split($0, a, " "); print a[1]}' | wc -l | tr -d '[:space:] ')

if ! [[ $POD_COUNT = 4 ]] ; then
   echo "Error: Pod Count mismatch" ; exit 1
fi

# Get pod status
for i in 1 2 3 4 
do
  pod_status=$(kubectl get pods -n kube-system | grep ^${releaseName}-  | awk '{split($0, a, " "); print a[3]}' | sed -n ''$i' p')
  echo $pod_status
  if ! [[ $pod_status = Running ]] ; then
   echo "Error: Pod Not Running" ; exit 1
   fi
done 


# Get search service count 
SERVICE_COUNT=$(kubectl get service  -n kube-system | grep ^${releaseName}-  | awk '{split($0, a, " "); print a[1]}' | wc -l | tr -d '[:space:] ')

if ! [[ $SERVICE_COUNT = 3 ]] ; then
   echo "Error: Service Count mismatch" ; exit 1
fi


echo "Helm Install Test Sucessful" 
exit 0
