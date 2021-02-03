#!/bin/bash

# TAKEN FROM https://askubuntu.com/questions/1029562/move-snap-packages-to-another-location-directory

# I RECCOMMEND ONLY MOVING SNAP DATA. ONLY MOVE SNAPS IF YOU REALLY HAVE TO

#Create the directory
newSnapAppLocation='/disk1/snapd'
newSnapDataLocation='/disk1/snap'

oldSnapAppLocation='/var/lib/snapd'
oldSnapDataLocation='/var/snap'
sudo mkdir $newSnapAppLocation
sudo mkdir $newSnapDataLocation

#Copy the data
sudo rsync -avzP $oldSnapAppLocation/  $newSnapAppLocation
sudo rsync -avzP $oldSnapDataLocation/  $newSnapDataLocation

#Do backups
sudo mv $oldSnapAppLocation $oldSnapAppLocation.bak
sudo mv $oldSnapDataLocation $oldSnapDataLocation.bak
sudo cp /etc/fstab /etc/fstab.bak

#Change fstab
echo "$newSnapAppLocation $oldSnapAppLocation none bind 0 0" | sudo tee -a /etc/fstab
echo "$newSnapDataLocation $oldSnapDataLocation none bind 0 0" | sudo tee -a /etc/fstab

#remount fstab Or reboot.
sudo mkdir $oldSnapAppLocation
sudo mkdir $oldSnapDataLocation
sudo mount -a

if ls  $oldSnapAppLocation/ | grep snaps
then
    echo "Re-mounting snapd folder is done successfully. !!!!"
    sudo rm -rf $oldSnapAppLocation.bak
else
    echo "WARNING : Re-mounting snapd folder failed, please revert !!!!! "

    # Trying to revert automatically
    sudo cp /etc/fstab.bak /etc/fstab

    sudo mount -a
    sudo umount $oldSnapAppLocation

    sudo mv $oldSnapAppLocation.bak $oldSnapAppLocation

    echo "Files located at $newSnapAppLocation should be removed"
fi

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
