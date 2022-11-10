#!/bin/bash

read -p "kube config file name to be created e.g napp-kube-config.yml: " TO_BE_CREATED_KUBECONFIG_FILE_READ


if [[ -z $TO_BE_CREATED_KUBECONFIG_FILE_READ ]]

then

TO_BE_CREATED_KUBECONFIG_FILE='napp-kube-config.yml'

else

TO_BE_CREATED_KUBECONFIG_FILE=$TO_BE_CREATED_KUBECONFIG_FILE_READ

fi

kubectl create serviceaccount napp-admin -n kube-system

sleep 1

kubectl create clusterrolebinding napp-admin --serviceaccount=kube-system:napp-admin --clusterrole=cluster-admin

sleep 1

SECRET=$(kubectl get serviceaccount napp-admin -n kube-system -ojsonpath='{.secrets[].name}')

sleep 1

TOKEN=$(kubectl get secret $SECRET -n kube-system -ojsonpath='{.data.token}' | base64 -d)

sleep 1

kubectl get secrets $SECRET -n kube-system -o jsonpath='{.data.ca\.crt}' | base64 -d > ./ca.crt

sleep 1

CONTEXT=$(kubectl config view -o jsonpath='{.current-context}')

sleep 1

CLUSTER=$(kubectl config view -o jsonpath='{.contexts[?(@.name == "'"$CONTEXT"'")].context.cluster}')

sleep 1

URL=$(kubectl config view -o jsonpath='{.clusters[?(@.name == "'"$CLUSTER"'")].cluster.server}')

sleep 1

kubectl config --kubeconfig=$TO_BE_CREATED_KUBECONFIG_FILE set-cluster $CLUSTER --server=$URL --certificate-authority=./ca.crt --embed-certs=true

sleep 1

kubectl config --kubeconfig=$TO_BE_CREATED_KUBECONFIG_FILE set-context $CONTEXT --cluster=$CLUSTER --user=napp-admin

sleep 1

kubectl config --kubeconfig=$TO_BE_CREATED_KUBECONFIG_FILE use-context $CONTEXT

sleep 1

echo "Kube config file created "$TO_BE_CREATED_KUBECONFIG_FILE
