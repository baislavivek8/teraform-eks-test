#!/bin/sh
######## this will delete all apps in dev qa and stage as well as logging and monitering services in cluster#############
echo "**********************Deleting new relic services******************************"
kubectl delete all --all -n newrelic
kubectl delete all --all -n px-operator
kubectl delete namespace newrelic
echo "**********************Deleting HPA******************************"
kubectl delete -f $HOME/aakash-terraform/post_script/hpa
echo "**********************Deleting VPA******************************"
kubectl delete -f $HOME/aakash-terraform/post_script/vpa
echo "**********************Deleting VPA Services******************************"
sh $HOME/aakash-terraform/post_script/vertical-pod-autoscaler/hack/vpa-down.sh
echo "**********************Deleting Metric Server******************************"
kubectl delete -f $HOME/aakash-terraform/post_script/metric-server
echo "**********************Deleting Development env apps******************************"
kubectl delete -f $HOME/aakash-terraform/post_script/apps/
echo "**********************Deleting Testing env apps******************************"
kubectl delete -f $HOME/aakash-terraform/post_script/apps/test-env
echo "**********************Deleting Logging configurations******************************"
kubectl delete -f $HOME/aakash-terraform/post_script/logging
echo "**********************Deleting namespaces******************************"
kubectl delete -f $HOME/aakash-terraform/post_script/namespaces
echo "**********************DONE******************************"
cd $HOME/aakash-terraform
terraform destroy -var-file="dev.tfvars"




