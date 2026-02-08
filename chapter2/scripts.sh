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

# 오라클 개발자용 23c 설치 - 근데 이건 쓸모 있나?
# 여기는 아래 도커 설치로...
sudo apt update && sudo apt upgrade -y
sudo apt-get install ca-certificates curl gnupg lsb-release
sudo apt autoremove
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl status docker
sudo usermod -aG docker $USER
newgrp docker
docker version
docker run hello-world

# 1. 오라클 데이터베이스 23ai (23c) Free 이미지 pull
sudo docker pull container-registry.oracle.com/database/free:latest

# 2. 컨테이너 실행 - 그냥 버전
sudo docker run -d --name oracle23ai \
-p 1521:1521 -p 5500:5500 \
-e ORACLE_PWD=YourSecurePassword123! \
container-registry.oracle.com/database/free:latest

# 2. 컨테이너 실행 - 이게 플러거블인지 나발인지...
sudo docker run -d --name oracle23ai \
-p 1521:1521 \
-e ORACLE_PWD=YourSecurePassword123! \
-v /opt/oracle/oradata:/opt/oracle/oradata \
://

sudo docker exec -it oracle23ai bash -c "source /home/oracle/.bashrc; sqlplus / as sysdba"

-- CDB$ROOT에 있는지 확인
SHOW CON_NAME;

-- 새로운 PDB 생성 (PDB$SEED 사용)
CREATE PLUGGABLE DATABASE TESTPDB 
ADMIN USER pdbadmin IDENTIFIED BY YourPDBPassword123!
FILE_NAME_CONVERT=('/opt/oracle/oradata/FREE/pdbseed/', '/opt/oracle/oradata/FREE/TESTPDB/');

-- PDB 오픈
ALTER PLUGGABLE DATABASE TESTPDB OPEN;

-- PDB를 현재 컨테이너로 설정하여 서비스 저장
ALTER SESSION SET CONTAINER = TESTPDB;
ALTER SYSTEM REGISTER;

-- PDB 목록 및 상태 확인
SHOW PDBS;
EXIT;


# 컨테이너 상태 확인
sudo docker ps
# SQL*Plus로 접속 (컨테이너 내부)
sudo docker exec -it oracle23ai sqlplus sys/YourSecurePassword123!@FREEPDB1 as sysdba
# OCI 방화벽(iptables) 해제
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 1521 -j ACCEPT
sudo netfilter-persistent save

#-----------------------도커 설치---------------------------------
sudo apt-get update
