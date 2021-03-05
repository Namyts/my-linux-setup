#!/bin/bash

cd ~

#exec su -l $USER #REDO GROUPS
#IS_WSL

#update things.
sudo apt-get update && sudo apt-get -y upgrade

sudo apt install -y net-tools
sudo apt install -y neofetch

#create on-bash.sh
# ON_BASH_SCRIPT=/mnt/c/Users/james/OneDrive/Documents/Projects/WSL/on-bash.sh
ON_BASH_SCRIPT=~/my-wsl-setup/Linux/on-bash.sh

source $ON_BASH_SCRIPT #so i can use the functions/variables
writeOnce .bashrc source "$ON_BASH_SCRIPT"
sudo chmod +x $ON_BASH_SCRIPT

#remove sudo password requirement
writeOnce /etc/sudoers.d/$USER "$USER ALL=(ALL) NOPASSWD:ALL"

#setup ssh
mkdir -p ~/.ssh
sudo apt-get remove -y --purge openssh-server
sudo apt-get update && sudo apt-get -y upgrade
sudo apt-get install -y openssh-server

#change ssh port
writeOnce /etc/ssh/sshd_config "Port 2222"
sudo ufw allow 2222/tcp
sudo service ssh restart

IP=$(echo -n $(ipconfig))
#add work keys into .ssh
echo "Add your ssh keys to the ssh folder"
echo "On windows run:"
echo "scp -P 2222 * $USER@$IP:/home/$USER/.ssh"
echo "or on WSL"
echo "cd /mnt/c/Users/james/OneDrive/Documents/Projects/WSL/ssh && cp -a . ~/.ssh && cd ~"
read -n 1 -s -r -p "Press any key to continue"
echo ""

touch ~/.ssh/authorized_keys
cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys
chmod 600 ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/authorized_keys
writeOnce /etc/ssh/sshd_config "PasswordAuthentication no"
sudo service ssh restart

##enable systemd scripts for snaps etc...
#cd /
#git clone https://github.com/DamionGans/ubuntu-wsl2-systemd-script.git
#sudo git clone https://github.com/Namyts/ubuntu-wsl2-systemd-script.git
#cd ubuntu-wsl2-systemd-script/
#sudo bash ubuntu-wsl2-systemd-script.sh --force
#cd ~

# HARD RESTART!
# WAIT FOR SNAP TO BE READY!

#run "sudo apt purge snapd && sudo apt install snapd" if something weird breaks
sudo snap install robo3t-snap

sudo snap install epiphany

sudo snap install prospect-mail

sudo snap install node --classic
mkdir -p ~/.npm-global

#### SOFT RESTART #### PATH
source ~/.bashrc

npm config set prefix '~/.npm-global'

sudo snap install docker
sudo groupadd docker
sudo gpasswd -a $USER docker 
#sudo usermod -aG docker $USER

sudo snap install microk8s --classic
sudo gpasswd -a $USER microk8s 
#sudo usermod -aG microk8s $USER
mkdir -p ~/.kube

#### SOFT RESTART #### PATH | PERMISSIONS
source ~/.bashrc

sudo microk8s config > ~/.kube/config #sudo bc the permissions dont update

sudo apt install curl
#sudo apt install --reinstall ca-certificates #if something goes wrong with the next command

( #install kubctl krew
  set -x; cd "$(mktemp -d)" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.{tar.gz,yaml}" &&
  tar zxvf krew.tar.gz &&
  KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_amd64" &&
  "$KREW" install --manifest=krew.yaml --archive=krew.tar.gz &&
  "$KREW" update
)

#### SOFT RESTART #### PATH
source ~/.bashrc

sudo snap install kubectl --classic
sudo snap install kustomize
# sudo snap install helm3
sudo snap install helm --classic

#### SOFT RESTART #### PATH
source ~/.bashrc

kubectl krew install ctx
kubectl krew install ns


#setup microk8s
sudo microk8s enable dns #sudo bc the permissions dont update
sudo microk8s enable dashboard #sudo bc the permissions dont update
sudo microk8s enable ingress #sudo bc the permissions dont update
#microk8s enable host-access #sudo bc the permissions dont update

kubectl create ns flux

helm repo add fluxcd https://charts.fluxcd.io
helm repo update
helm upgrade -i helm-operator fluxcd/helm-operator \
    --namespace flux \
    --set helm.versions=v3

#for openebs to work
sudo apt-get install -y open-iscsi
sudo systemctl enable --now iscsid
