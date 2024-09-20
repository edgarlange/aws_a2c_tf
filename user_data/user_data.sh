#!/bin/bash
echo "Ejecutando Scripts cnam..."

echo "Ejecutando yum update..."
sudo yum update -y && sudo yum upgrade -y

#install docker (REDHAT y CentOS, Amazon Linux)
# sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum install docker -y
sudo usermod -aG docker ec2-user
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo systemctl status docker.service
docker --version

echo "ec2-user ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee "/etc/sudoers.d/ec2-user"
echo "Defaults:ec2-user    !requiretty" | sudo tee -a "/etc/sudoers.d/ec2-user"

sudo docker run hello-world
curl -o AWSApp2Container-installer-linux.tar.gz https://app2container-release-us-east-1.s3.us-east-1.amazonaws.com/latest/linux/AWSApp2Container-installer-linux.tar.gz
sudo tar xvf AWSApp2Container-installer-linux.tar.gz
sudo ./install.sh

