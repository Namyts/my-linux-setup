#!/bin/bash

# [[ $TERM != "screen" ]] && exec screen -q
(command -v screen > /dev/null) && [[ $TERM = "xterm-256color" ]] && exec screen -q

(command -v neofetch > /dev/null) && neofetch

WINDOWS_IP=192.168.0.177
ON_BASH_LOCATION=~/my-linux-setup
WORK_K8_LOCATION=~/evn-kubernetes-config
MY_K8S_LOCATION=~/my-k8s
YAML_DOCS_FILTER_LOCATION=~/yaml-docs-filter
WIFI_ADAPTER=enp0s3


if [[ -n "$IS_WSL" || -n "$WSL_DISTRO_NAME" ]]; then
    echo "This is WSL"
	WINDOWS_IP=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
	ON_BASH_LOCATION=/mnt/c/Users/james/OneDrive/Documents/Projects/WSL/
	WORK_K8_LOCATION=/mnt/d/james/Execview/Kubernetes
	MY_K8S_LOCATION=/mnt/d/james/code/my-k8s
	YAML_DOCS_FILTER_LOCATION=/mnt/d/james/Execview/yaml-docs-filter
	WIFI_ADAPTER=eth0
fi

(command -v docker > /dev/null) && (snap services docker > /dev/null || sudo snap start docker)
(service ssh status > /dev/null || sudo service ssh start)

export DISPLAY=$WINDOWS_IP:0
export NO_AT_BRIDGE=1
export DISABLE_WAYLAND=1
unset XDG_RUNTIME_DIR
unset DBUS_SESSION_BUS_ADDRESS

# (command -v microk8s > /dev/null) && microk8s config > ~/.kube/config

alias ducks="sudo du -h --max-depth=1"
alias mail=prospect-mail
alias robomongo=robo3t-snap
alias web=epiphany
alias dns="cat /etc/resolv.conf | awk '/nameserver/{print \$2}'"

alias k='kubectl'
alias kubens="k ns"
alias kubectx="k ctx"
alias update-hosts="source $ON_BASH_LOCATION/Linux/scripts/add-aliases-to-hosts.sh"
alias dashboard="source $WORK_K8_LOCATION/scripts/dashboard.sh"
alias my-dashboard="source $MY_K8S_LOCATION/scripts/dashboard.sh"
alias ev-deploy="source $ON_BASH_LOCATION/Linux/scripts/deploy-k8s.sh"
alias my-deploy="bash $MY_K8S_LOCATION/scripts/deploy.sh"

(command -v kubectl > /dev/null) && source <(kubectl completion bash)
(command -v kubectl > /dev/null) && source <(k completion bash)
(command -v kubectl > /dev/null) && complete -F __start_kubectl k

(command -v yq > /dev/null) && source <(yq shell-completion bash)

alias ipconfig="echo \$(ifconfig $WIFI_ADAPTER | awk '{print \$2}' | grep -E -o \"([0-9]{1,3}[\.]){3}[0-9]{1,3}\")"
alias kustomize-filter="$YAML_DOCS_FILTER_LOCATION/index.js"

function ev-connections {
	bash $ON_BASH_LOCATION/Linux/scripts/k8s-connections.sh $1
}

function my-connections {
	bash $MY_K8S_LOCATION/scripts/connections.sh $1
}

function delete-error-pods {
	local ns=$1
	if [ "$1" = "" ]; then 
		ns=local
	fi
	k get pods -n $ns | grep -v Running | grep -v ContainerCreating | awk '{print $1}' | tail +2 | xargs kubectl delete pods -n $ns
}

function delete-error-deployments {
	local ns="$1"
	if [ "$1" = "" ]; then 
		ns=local
	fi
	k get deployments -n $ns | grep -vP '(\d+)\/\1' | awk '{print $1}' | tail +2 | xargs kubectl delete deployments -n $ns
}


function highlight {
	local pattern="$1"
	shift
    grep --color -E "$pattern|$" "$@"
}

function writeOnce {
	local write_file="$1"
	shift
    local string_to_write="$@"
	grep -q "$string_to_write" $write_file || (echo $string_to_write | sudo tee -a $write_file)
}

alias get-tls-crt="kubectl get secret tls-secret -n dev -oyaml | yq '.data[\"tls.crt\"]' | base64 -d"
alias get-tls-crt="kubectl get secret tls-secret -n dev -oyaml | yq '.data[\"tls.key\"]' | base64 -d"

# alias update-tls="get-live-tls-secret | yq e '.metadata.namespace = \"cert-manager\"' - | k apply -f -"

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

if [[ -n "$IS_WSL" || -n "$WSL_DISTRO_NAME" ]]; then
	ipfile=$ON_BASH_LOCATION/Windows/vw-aliases/config/ip
	oldip=$(cat $ipfile)
	newip=$(echo -n $(ipconfig))
	if [ "$oldip" != "$newip" ]; then
		echo -n $(ipconfig) > $ipfile #put wsl2 ip in file
		sleep 1
		
		cat /mnt/c/Windows/System32/drivers/etc/hosts | grep \#VM-Alias | sudo tee -a /etc/hosts > /dev/null #reload
	fi
fi

alias update-coredns="source $ON_BASH_LOCATION/Linux/scripts/replace-coredns-nameserver.sh"

export LIBGL_ALWAYS_INDIRECT=1
export PATH=$newPath
export KUBECONFIG=~/.kube/config

newip=$(echo -n $(ipconfig))
echo "IP: $newip"

export WINDOWS_IP
export IP=$newip
export ON_BASH_LOCATION
export WORK_K8_LOCATION
export MY_K8S_LOCATION
export YAML_DOCS_FILTER_LOCATION
export WIFI_ADAPTER
