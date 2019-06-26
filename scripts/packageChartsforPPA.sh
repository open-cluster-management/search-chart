#!/bin/bash
# Licensed Materials - Property of IBM
# 5737-E67
# (C) Copyright IBM Corporation 2016, 2019 All Rights Reserved
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.


SHELL="/bin/bash"
STABLE_BUILD_DIR=$1
STABLE_CHARTS_DIR=$2
STABLE_CHARTS=`ls $STABLE_CHARTS_DIR`

if [ ! -d $STABLE_BUILD_DIR ]
then
        mkdir -p $STABLE_BUILD_DIR
fi

# Package all the directories in STABLE_CHARTS_DIR to STABLE_BUILD_DIR
for chart in $STABLE_CHARTS;
do
    printf  "CHARTNAME\t %s\n"  $STABLE_CHARTS_DIR/$chart
    # Move the values-packaging.yaml to values.yaml
    if [ -e $STABLE_CHARTS_DIR/$chart/values-packaging.yaml ]
    then
	    cp $STABLE_CHARTS_DIR/$chart/values.yaml $STABLE_CHARTS_DIR/$chart/values_backup.yaml
	    mv $STABLE_CHARTS_DIR/$chart/values-packaging.yaml $STABLE_CHARTS_DIR/$chart/values.yaml
        printf  "\t%s\n"  "Moved values-packaging.yaml to values.yaml"
    fi

    printf  "\t"
    helm package  $STABLE_CHARTS_DIR/$chart  -d $STABLE_BUILD_DIR

    # Revert the above move the values-packaging.yaml to values.yaml
    if [ -e $STABLE_CHARTS_DIR/$chart/values_backup.yaml ]
    then
	    mv $STABLE_CHARTS_DIR/$chart/values.yaml $STABLE_CHARTS_DIR/$chart/values-packaging.yaml
	    cp $STABLE_CHARTS_DIR/$chart/values_backup.yaml $STABLE_CHARTS_DIR/$chart/values.yaml
	    rm $STABLE_CHARTS_DIR/$chart/values_backup.yaml
        printf  "\t%s\n"  "Reverted the values.yaml to original values."
    fi
done
