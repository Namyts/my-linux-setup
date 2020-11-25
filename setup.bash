#remember to ensure wsl is version 2.
#look in the on-bash.sh file to ssee what automatically gets set up. Should also clear up file location issues
cd ~

#remove sudo password requirement
echo "namyts ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/namyts

#update things.
sudo apt-get update && sudo apt-get -y upgrade

#enable systemd scripts for snaps etc...
cd /
# git clone https://github.com/DamionGans/ubuntu-wsl2-systemd-script.git
sudo git clone https://github.com/Namyts/ubuntu-wsl2-systemd-script.git
cd ubuntu-wsl2-systemd-script/
sudo bash ubuntu-wsl2-systemd-script.sh --force
cd ~


# on windows set this up https://stackoverflow.com/questions/42758985/windows-auto-start-pm2-and-node-apps
# run it on ./wsl2aliases/index.js

# HARD RESTART!
# WAIT FOR SNAP TO BE READY!

#setup ssh
sudo apt-get remove -y --purge openssh-server
sudo apt-get update && sudo apt-get -y upgrade
sudo apt-get install -y openssh-server

#change ssh port
sudo apt install -y net-tools
echo "Port 2222" | sudo tee -a /etc/ssh/sshd_config
echo "PasswordAuthentication no" | sudo tee -a /etc/ssh/sshd_config

sudo ufw allow 2222/tcp
sudo service ssh restart

#add work keys into .ssh
cd /mnt/c/Users/james/OneDrive/Documents/Projects/WSL/ssh
cp -a . ~/.ssh
cd ~
touch ~/.ssh/authorized_keys
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/id_rsa
chmod 600 ~/.ssh/authorized_keys

# remember to ssh at least once to
# - windows -> wsl2


#create on-bash.sh
echo "source /mnt/c/Users/james/OneDrive/Documents/Projects/WSL/on-bash.sh" | sudo tee -a .bashrc
sudo chmod +x /mnt/c/Users/james/OneDrive/Documents/Projects/WSL/on-bash.sh


#install opengl support for some gui apps
sudo apt install -y mesa-utils
sudo apt-get install -y x11-apps
sudo apt install -y --no-install-recommends ubuntu-desktop 

#start desktop (ensure vcxsrv doesnt have native openGl enabled...)
# sudo service dbus start
# sudo service x11-common start
# gnome-shell --x11 -r #run this to test


#install some apps
code-insiders .


#run "sudo apt purge snapd && sudo apt install snapd" if something weird breaks
sudo snap install robo3t-snap

sudo snap install epiphany

sudo snap install prospect-mail

sudo snap install node --classic
mkdir ~/.npm-global
#SOFT RESTART
npm config set prefix '~/.npm-global'

sudo snap install docker
sudo groupadd docker
sudo usermod -aG docker $USER
# enable docker api NOTE THIS DOESNT WORK ANYMORE!!!
# create /etc/docker/daemon.json
# {
# 	"hosts": ["unix:///var/run/docker.sock", "tcp://127.0.0.1:23750"]
# }
#idk if you need this line. but you can now use localhost on the windows machine
# sudo ufw allow 23750/tcp
# test with curl localhost:23750/images/json

sudo snap install microk8s --classic
sudo usermod -aG microk8s $USER
mkdir ~/.kube
microk8s config > ~/.kube/config

( #install kubctl krew
  set -x; cd "$(mktemp -d)" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.{tar.gz,yaml}" &&
  tar zxvf krew.tar.gz &&
  KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_amd64" &&
  "$KREW" install --manifest=krew.yaml --archive=krew.tar.gz &&
  "$KREW" update
)

#SOFT RESTART!

sudo snap install kubectl --classic
sudo snap install kustomize
# sudo snap install helm3
sudo snap install helm --classic

#SOFT RESTART!

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

#how to make block devices!
# blockdevicedisk='/k8storage/disks/diskimage'
# blockdevicesize=10000
# sudo dd if=/dev/zero of=$blockdevicedisk bs=1M count=$blockdevicesize
# sudo mkfs.ext4 $blockdevicedisk

# blockdevicedisk2='/k8storage/disks/diskimage2'
# blockdevicesize2=8000
# sudo dd if=/dev/zero of=$blockdevicedisk2 bs=1M count=$blockdevicesize2
# sudo mkfs.ext4 $blockdevicedisk2

