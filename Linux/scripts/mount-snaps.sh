#!/bin/bash

# TAKEN FROM https://askubuntu.com/questions/1029562/move-snap-packages-to-another-location-directory

#Create the directory
newSnapDataLocation='/disk1/snap'

oldSnapDataLocation='/var/snap'
sudo mkdir $newSnapDataLocation

#Copy the data
sudo rsync -avzP $oldSnapDataLocation/  $newSnapDataLocation

#Do backups
sudo mv $oldSnapDataLocation $oldSnapDataLocation.bak
sudo cp /etc/fstab /etc/fstab.bak

#Change fstab
echo "$newSnapDataLocation $oldSnapDataLocation none bind 0 0" | sudo tee -a /etc/fstab

#remount fstab Or reboot.
sudo mkdir $oldSnapDataLocation
sudo mount -a

if ls  $oldSnapDataLocation/ | grep core
then
    echo "Re-mounting snap folder is done successfully. !!!!"
    sudo rm -rf $oldSnapDataLocation.bak
	sudo rm /etc/fstab.bak
else
    echo "WARNING : Re-mounting snap folder failed, please revert !!!!! "

    # Trying to revert automatically
    sudo cp /etc/fstab.bak /etc/fstab

    sudo mount -a
    sudo umount $oldSnapDataLocation

    sudo mv $oldSnapDataLocation.bak $oldSnapDataLocation

    echo "Files located at $newSnapDataLocation should be removed"
fi
