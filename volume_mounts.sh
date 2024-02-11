#!/bin/bash
set -e

EBS_MOUNT_DIRECTORY=/var/data
EFS_ID=fs-047e86871ab5bdd12.efs.us-east-1.amazonaws.com
EFS_MOUNT_DIRECTORY=/var/efs

#### Create SWAP #####
dd if=/dev/zero of=/swapfile bs=128M count=32
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile swap swap defaults 0 0' >> /etc/fstab

#### Attach EBS ####
disk_type=xvdh

if lsblk -f | grep -wq $disk_type; then
    echo "Disk can be mounted"
    mkfs -t xfs /dev/$disk_type
    mkdir -p $EBS_MOUNT_DIRECTORY
    mount /dev/$disk_type $EBS_MOUNT_DIRECTORY

    # backup of the original fstab file
    cp /etc/fstab /etc/fstab.orig

    # get UUID of the mount
    fs_uuid=$(lsblk -no UUID /dev/$disk_type)

    # add the mount to fstab
    echo "UUID=$fs_uuid $EBS_MOUNT_DIRECTORY xfs defaults,nofail 0 2" >> /etc/fstab
else
    echo "Disk cannot be mounted. Check if EBS volume is attached to instance."
    exit 1
fi

# Install EFS mount helper
sudo yum install -y nfs-utils

# Create the mount directory
sudo mkdir -p "$EFS_MOUNT_DIRECTORY"

# Mount the EFS filesystem
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport "$EFS_ID:/" "$EFS_MOUNT_DIRECTORY"

# Check if EFS is already in fstab, add if not
if ! grep -qs "$EFS_ID:/" /etc/fstab; then
    echo "$EFS_ID:/ $EFS_MOUNT_DIRECTORY nfs4 defaults,_netdev 0 0" | sudo tee -a /etc/fstab
fi

# Remount all in fstab (with sudo)
sudo mount -a
