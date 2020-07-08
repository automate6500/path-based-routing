curl -fsSL https://get.docker.com/ | sudo sh
sudo systemctl start docker
sudo systemctl enable docker
#docker run --restart always --detach --name minion --publish PORT_NUMBER_HERE IMAGE_NAME_HERE
