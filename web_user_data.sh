#!/bin/bash -xe
export DOCKER_COMPOSE_VERSION=1.26.2
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker
curl -L \
    https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m) \
    -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
usermod -a -G docker ec2-user
docker info
docker-compose version
docker run --name ngx --restart always --detach --publish 3000:80 nginx
docker run --name web --restart always --detach --publish 80:80   benpiper/mtwa:web
docker run --name img --restart always --detach --publish 81:80   benpiper/imagegen
