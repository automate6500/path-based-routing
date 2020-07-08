#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user
docker info
docker run --name nginx --restart always --detach --publish 3000:80   nginx
docker run --name web   --restart always --detach --publish 80:80     benpiper/mtwa:web
docker run --name app   --restart always --detach --publish 8080:8080 benpiper/mtwa:app
