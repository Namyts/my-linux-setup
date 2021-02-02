#!/bin/bash

neofetch

(command -v docker > /dev/null) && (snap services docker > /dev/null || sudo snap start docker)
(service ssh status > /dev/null || sudo service ssh start)

export DISPLAY=192.168.0.18:0
export NO_AT_BRIDGE=1
unset XDG_RUNTIME_DIR
unset DBUS_SESSION_BUS_ADDRESS

(command -v microk8s > /dev/null) && microk8s config > ~/.kube/config

alias update-hosts='bash ~/my-wsl-setup/add-aliases-to-hosts.sh'
alias ducks='sudo du -h --max-depth=1'
alias mail='prospect-mail'
alias robomongo='robo3t-snap'
alias web='epiphany'
alias kubens='kubectl ns'
alias dashboard='bash ~/my-wsl-setup/get-token.sh'
alias ev-deploy='bash ~/evn-kubernetes-config/deploy.sh local'
alias my-deploy='bash ~/my-k8/deploy.sh'
alias dns="cat /etc/resolv.conf | awk '/nameserver/{print \$2}'"
(command -v kubectl > /dev/null) && source <(kubectl completion bash)
alias ipconfig="echo \$(ifconfig enp0s3 | awk '{print \$2}' | grep -E -o \"([0-9]{1,3}[\.]){3}[0-9]{1,3}\")"
alias k='kubectl'
alias kustomize-filter="/mnt/d/james/Execview/yaml-docs-filter/index.js"
alias delete-error-pods="k get pods -n dev | grep -v Running | grep -v ContainerCreating | awk '{print \$1}' | tail +2 | xargs kubectl delete pods -n dev"
alias delete-error-deployments="k get deployments -n dev | grep -vP '(\d+)\/\1' | awk '{print \$1}' | tail +2 | xargs kubectl delete deployments -n dev"

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

alias update-coredns='source ~/my-wsl-setup/replace-coredns-nameserver.sh'

export LIBGL_ALWAYS_INDIRECT=1
export PATH=$newPath
export KUBECONFIG=~/.kube/config

newip=$(echo -n $(ipconfig))
echo "IP: $newip"
