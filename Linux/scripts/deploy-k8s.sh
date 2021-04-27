currentContext=`kubectl config current-context`

echo "$currentContext"

k8env=``

if [ "$currentContext" = "microk8s" ]; then 
	k8env=local
fi

if [ "$currentContext" = "evn-cluster" ]; then 
	k8env=production
fi

if [ "$currentContext" = "" ]; then 
	echo "Current context was $currentContext"
	exit 1
fi


echo "Deploying $k8env to $currentContext"

bash $WORK_K8_LOCATION/scripts/deploy.sh $k8env