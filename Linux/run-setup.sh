#!/bin/bash
cd ~

sudo apt-get install -y git
git clone https://github.com/Namyts/my-wsl-setup.git

cd ~/my-wsl-setup/Linux
source ./setup.sh

