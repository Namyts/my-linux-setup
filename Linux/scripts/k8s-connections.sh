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
		echo "Since your context is $currentContext, you must select an environment"
		exit 1
	fi

	k8env=$argEnv
fi


echo "Connecting to $k8env services in $currentContext"

bash $WORK_K8_LOCATION/scripts/connections.sh $k8env