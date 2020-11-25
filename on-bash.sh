#!/bin/bash

(command -v docker > /dev/null) && (snap services docker > /dev/null || sudo snap start docker)
(service ssh status > /dev/null || sudo service ssh start)

export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0
export NO_AT_BRIDGE=1
unset XDG_RUNTIME_DIR
unset DBUS_SESSION_BUS_ADDRESS

(command -v microk8s > /dev/null) && microk8s config > ~/.kube/config

alias ducks='sudo du -h --max-depth=1'
alias mail='prospect-mail'
alias robomongo='robo3t-snap'
alias web='epiphany'
alias kubens='kubectl ns'
alias dashboard='bash /mnt/c/Users/james/OneDrive/Documents/Projects/WSL/get-token.sh'
alias deploy='bash /mnt/d/james/Execview/Kubernetes/deploy.sh local'
alias dns="cat /etc/resolv.conf | awk '/nameserver/{print \$2}'"
(command -v kubectl > /dev/null) && source <(kubectl completion bash)
alias ipconfig="echo \$(ifconfig eth0 | awk '{print \$2}' | grep -E -o \"([0-9]{1,3}[\.]){3}[0-9]{1,3}\")"
alias k='kubectl'
alias kustomize-filter="/mnt/d/james/Execview/yaml-docs-filter/index.js"

(command -v kubectl > /dev/null) && complete -F __start_kubectl k

function highlight {
	local pattern="$1"
	shift
    grep --color -E "$pattern|$" "$@"
}

alias execview-alpha='ssh -L 4002:127.0.0.1:4002 ubuntu@evn-alpha.evlem.net'
alias get-live-tls-secret="execview-alpha 'kubectl get secret tls-secret -n dev -o jsonpath={}'"
alias update-tls="get-live-tls-secret | k apply -f -"

declare -a blockDevicesAndLocations=("/k8storage/disks/diskimage loop0" "/k8storage/disks/diskimage2 loop1")
for bdandl in "${blockDevicesAndLocations[@]}"
do
	bdandlArray=($bdandl)
	bd=${bdandlArray[0]}
	l=${bdandlArray[1]}

	[ ! -f $bd ] || (lsblk | grep $l > /dev/null) || sudo losetup /dev/$l $bd
	#sudo losetup -d /dev/$1 #to remove, eg sudo losetup -d /dev/loop0
done


# add and remove from PATH
newPath="${PATH}"

declare -a removeFromPath=("/mnt/c/nodejs/npm" "/mnt/c/nodejs/node/")
declare -a addToPath=("${HOME}/.krew/bin" "/snap/bin" "~/.npm-global/bin")

for remove in "${removeFromPath[@]}"
do
	#echo "removing ${remove}"
	newPath=$(echo $newPath | sed "s|:${remove}:||g")
done
for add in "${addToPath[@]}"
do
	#echo "adding ${add}"
	newPath="${newPath}:${add}"
done

ipfile=/mnt/c/Users/james/OneDrive/Documents/Projects/WSL/wsl2aliases/ip
oldip=$(cat $ipfile)
newip=$(echo -n $(ipconfig))
if [ "$oldip" != "$newip" ]; then
	echo -n $(ipconfig) > $ipfile #put wsl2 ip in file
	sleep 1
	
	cat /mnt/c/Windows/System32/drivers/etc/hosts | grep \#WSL2Alias | sudo tee -a /etc/hosts > /dev/null #reload
fi

alias update-coredns='source /mnt/c/Users/james/OneDrive/Documents/Projects/WSL/replace-coredns-nameserver.sh'

export LIBGL_ALWAYS_INDIRECT=1
export PATH=$newPath
export KUBECONFIG=~/.kube/config
