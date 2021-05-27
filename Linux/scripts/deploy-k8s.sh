currentContext=`kubectl config current-context`

echo "$currentContext"

k8env=""

if [ "$currentContext" = "" ]; then 
	echo "Current context was empty"
	exit 1
fi

if [ "$currentContext" = "microk8s" ]; then 
	k8env=local
fi

if [ "$currentContext" = "evn-cluster" ]; then 
	argEnv="$1"
	if [ "$argEnv" = "" ]; then 
		argEnv='development'
	fi

	k8env="$argEnv"
fi


echo "Deploying $k8env to $currentContext"

bash $WORK_K8_LOCATION/scripts/deploy.sh $k8env