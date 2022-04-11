#!/bin/bash

(
    echo n
    echo p
    echo 1
    echo
    echo
    echo w
) | sudo fdisk /dev/sdb

(
    echo n
    echo p
    echo 1
    echo
    echo
    echo w
) | sudo fdisk /dev/sdc

vgcreate data /dev/sdb1 /dev/sdc1

lvcreate -L 1G -n docker data

mkfs.xfs /dev/data/docker

mkdir /var/lib/docker

docker_uuid=$(blkid -s UUID -o value /dev/mapper/data-docker)

echo "UUID=${docker_uuid}  /var/lib/docker xfs defaults   0   2" >> /etc/fstab

mount -a

mkdir /build

./createHtml.sh
./createDockerfile.sh

docker build -t examimage .

docker run -d -p 80:80 --name serverinfo examimage

docker update --restart=always 3ec9e89009ff