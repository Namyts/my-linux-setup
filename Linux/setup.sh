#!/bin/bash

cd ~

#exec su -l $USER #REDO GROUPS
#IS_WSL

#remove sudo password requirement
echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/$USER

#update things.
sudo apt-get update && sudo apt-get -y upgrade

sudo apt install -y net-tools

#setup ssh
mkdir -p ~/.ssh
sudo apt-get remove -y --purge openssh-server
sudo apt-get update && sudo apt-get -y upgrade
sudo apt-get install -y openssh-server

#change ssh port
echo "Port 2222" | sudo tee -a /etc/ssh/sshd_config
sudo ufw allow 2222/tcp
sudo service ssh restart

#add work keys into .ssh

echo "Add your ssh keys to the ssh folder"
echo "On windows run:"
echo "scp -P 2222 * $USER@192.168.0.69:/home/$USER/.ssh"
echo "or on WSL"
echo "cd /mnt/c/Users/james/OneDrive/Documents/Projects/WSL/ssh && cp -a . ~/.ssh && cd ~"
read -n 1 -s -r -p "Press any key to continue"
echo ""

touch ~/.ssh/authorized_keys
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/authorized_keys
echo "PasswordAuthentication no" | sudo tee -a /etc/ssh/sshd_config
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

# remember to ssh at least once to
# - windows -> wsl2


#create on-bash.sh

# ON_BASH_LOCATION=/mnt/c/Users/james/OneDrive/Documents/Projects/WSL/on-bash.sh
ON_BASH_LOCATION=~/my-wsl-setup/on-bash.sh

echo "source $ON_BASH_LOCATION" | sudo tee -a .bashrc
sudo chmod +x $ON_BASH_LOCATION

sudo apt install -y neofetch

#install opengl support for some gui apps
# sudo apt install -y mesa-utils
# sudo apt-get install -y x11-apps
# sudo apt install -y --no-install-recommends ubuntu-desktop 

#start desktop (ensure vcxsrv doesnt have native openGl enabled...)
# sudo service dbus start
# sudo service x11-common start
# gnome-shell --x11 -r #run this to test

#run "sudo apt purge snapd && sudo apt install snapd" if something weird breaks
sudo snap install robo3t-snap

sudo snap install epiphany

sudo snap install prospect-mail

sudo snap install node --classic
mkdir ~/.npm-global

#### SOFT RESTART ####
exec su -l $USER

npm config set prefix '~/.npm-global'

sudo snap install docker
sudo groupadd docker
sudo usermod -aG docker $USER

sudo snap install microk8s --classic
sudo usermod -aG microk8s $USER
mkdir ~/.kube

#### SOFT RESTART ####
exec su -l $USER

microk8s config > ~/.kube/config

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

#### SOFT RESTART ####
exec su -l $USER

sudo snap install kubectl --classic
sudo snap install kustomize
# sudo snap install helm3
sudo snap install helm --classic

#### SOFT RESTART ####
exec su -l $USER

kubectl krew install ctx
kubectl krew install ns


#setup microk8s
microk8s enable dns
microk8s enable dashboard
microk8s enable ingress
#microk8s enable host-access

kubectl create ns flux

helm repo add fluxcd https://charts.fluxcd.io
helm repo update
helm upgrade -i helm-operator fluxcd/helm-operator \
    --namespace flux \
    --set helm.versions=v3

