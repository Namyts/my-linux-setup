#!/bin/bash
cd ~

sudo apt-get install -y git
git clone https://github.com/Namyts/my-linux-setup.git

cd ~/my-linux-setup/Linux
source ./setup.sh

