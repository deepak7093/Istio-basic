#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -p project -r region -s service-account -c cluster"
   echo -e "\t-p GCP project ID"
   echo -e "\t-r GCP K8 cluster region"
   echo -e "\t-s serviceaccount for istio"
   echo -e "\t-c K8 cluster name"
   exit 1 # Exit script after printing help
}

while getopts "p:r:s:c:" opt
do
   case "$opt" in
      p ) project="$OPTARG" ;;
      r ) region="$OPTARG" ;;
      s ) service_account="$OPTARG" ;;
      c ) cluster="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$project" ] || [ -z "$region" ] || [ -z "$service_account" ] || [ -z "$cluster" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

# Begin script in case all parameters are correct
echo "$project" "$region" "$service_account" "$cluster"


gcloud beta container clusters get-credentials "$cluster"  --region "$region" --project "$project"
kubectl create clusterrolebinding istio-admin --clusterrole=cluster-admin --serviceaccount="$service_account"
curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.1.0 sh -
cd istio-1.1.0/install/kubernetes
kubectl apply -f istio-demo-auth.yaml
kubectl label namespace default istio-injection=enabled
kubectl get all -n istio-system

