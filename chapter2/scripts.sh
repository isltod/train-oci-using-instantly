# 시스템 업데이트
sudo apt update && sudo apt upgrade -y

# 필요 패키지 설치
sudo apt install -y ca-certificates curl gnupg lsb-release

# 도커 공식 GPG 키 설치
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 도커 리포지토리 추가
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 도커 엔진 설치
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 도커에서 sudo 사용하지 않도록 그룹 추가
sudo usermod -aG docker ubuntu
newgrp docker

# 도커 서비스로 등록
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl status docker

# 버전 확인
docker version

# 도커 허브 로그인
docker login -u wolf@teoal.net

# 도커 허브 이미지 검색
docker search oraclelinux

# 도커 이미지 끌어와서 Nginx 실행
docker run -it --rm -d -p 8080:80 --name web nginx

# 도커 이미지, 컨테이너 정보
docker images
docker ps -a
docker inspect web

# 컨테이너 내 쉘 실행
docker exec -it web /bin/bash
hostname
ls
exit

# 특정 명령어 실행
docker exec -it web whoami

# 작업 디렉토리 지정
docker exec -w /var/log web cat dpkg.log

# 설치한 Nginx 로컬 확인 - Ingress 규칙 추가하고, 아래 실행후 로컬에서 확인
sudo iptables -I INPUT -p tcp --dport 8080 -j ACCEPT
sudo netfilter-persistent save
curl ifconfig.co

# 접속 결과 로그 확인
docker logs web