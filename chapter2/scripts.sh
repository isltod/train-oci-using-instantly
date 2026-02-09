#---------------------------------------------------------------------------------
# 새 인스턴스 만들고 도커 설치하고 연습
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

# 현재 외부 IP 확인
curl ifconfig.co

# 접속 결과 로그 확인
docker logs web

# Nginx 초기화면 수정
docker stop web
mkdir demo-content
vim demo-content/index.html
#index.html 작성
docker run -it --rm -d -p 8080:80 --name web -v ~/demo-content:/usr/share/nginx/html nginx
docker ps -a
#로컬에서 다시 확인
docker stop web

# 위 내용을 이미지 빌드로 처리
vi Dockerfile
#Dockerfile 내용 작성
docker build -t webserver .
docker images
docker run -it --rm -d -p 8080:80 --name web webserver
docker ps -a
#로컬에서 다시 확인

# 빌드 이미지를 리포지토리에 공유
#docker tag local-image:tag username/repository:tag
docker tag webserver karma999/webserver:1.0
docker images
docker push karma999/webserver:1.0

#---------------------------------------------------------------------------------
# 프라이빗 서브넷에 디비 서버 만들고 퍼블릭 서브넷 서버로 Bastion 연결하기 - 쓸모 없음

# 프라이빗 서브넷에 인스턴스 만들고 sftp로 프라이빗 키 업로드 - 키 파일 경로에서 실행
sftp -i ./id_rsa ubuntu@168.107.9.193
put id_rsa
quit

# 로컬에서 아래 명령으로 열거나...
ssh -i .\id_rsa -t -o ProxyCommand="ssh -W %h:%p ubuntu@168.107.9.193 -i ./id_rsa" ubuntu@10.0.1.29
plink.exe -ssh -i "c:\Users\wolf\.ssh\id_rsa" ubuntu@168.107.9.193 -nc %host:%port
# Pageant 실행해서 프라이빗 키 파일 등록하고 띄워놓은 상태에서, Putty 설정에 Connection>SSH>Auth 항목의 Allow agent forwarding 선택하고 점프하거나...

# but 이렇게 설치해봐야 프라이빗 서브넷에서는 NAT 게이트웨이를 은근슬쩍 빼놔서 외부 접속이 안되니 쓸모없음...
#---------------------------------------------------------------------------------

# 스왑 4G 설정
free -h
sudo dd if=/dev/zero of=/swapfile bs=1M count=4096
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
free -h

docker logs -f oracle23ai
Password cannot be null. Enter password