#!/bin/bash
cd ~

sudo apt-get install git 
git config --global user.name namyts
git config --global user.email 35004248+Namyts@users.noreply.github.com
git clone https://github.com/Namyts/my-wsl-setup.git

cd ~/my-wsl-setup
sudo ./setup.sh

