# 도커 관련 삭제 - 필요하면...
sudo docker rm -f $(sudo docker ps -qa)
sudo systemctl stop docker
sudo systemctl stop docker.socket
sudo apt-get purge -y docker.io docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-rootless-extras
sudo apt-get autoremove -y --purge
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
sudo rm -rf /etc/docker

# 도커 확인
sudo dpkg -l | grep docker
