hostsFile=/etc/hosts
cat $hostsFile | grep -v \#VM-Alias | sudo tee $hostsFile &> /dev/null

corednsConfigMapFile=$WORK_K8_LOCATION/overlays/local/resources/coredns-configmap.yaml
cat $corednsConfigMapFile | grep -v \#VM-Alias | sudo tee $corednsConfigMapFile &> /dev/null

aliasString=`cat $ON_BASH_LOCATION/Windows/vm-aliases/config/aliases`
ip=$(ifconfig enp0s3 | awk '{print $2}' | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}")

CoreDNSLineNumber=$(awk '/custom\.hosts/{ print NR; exit }' $WORK_K8_LOCATION/overlays/local/resources/coredns-configmap.yaml)

CoreDNSLineNumber=$(($CoreDNSLineNumber+1))

read -a arr <<< $aliasString
for a in "${arr[@]}"; do
	text="$ip	$a #VM-Alias"
	tabbyText="          "$text
	echo -e "$text" | sudo tee -a $hostsFile &> /dev/null
	sed -i "${CoreDNSLineNumber}i\\${tabbyText}" $corednsConfigMapFile #&> /dev/null
done

pod=$(kubectl get pods -n kube-system | awk '{print $1}' | grep coredns)
kubectl delete pod -n kube-system $pod