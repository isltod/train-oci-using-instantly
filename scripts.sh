# 디비 서버-----------------------------------------------------------------
# MySQL 3306 포트 열기
sudo iptables -I INPUT 6 -p tcp --dport 3306 -m state --state NEW -j ACCEPT
sudo netfilter-persistent save

# MySQL 설치
sudo apt update
sudo apt install mysql-server -y

# MySQL 설치 확인
mysql --version

# MySQL 서비스 시작 설정
sudo systemctl enable mysql
sudo service mysql status

# MySQL 보안 설정 - 해야 한다지만, 연습이니 귀찮아서 패스
#sudo mysql_secure_installation

# 보안 설정 없이 그냥 연결 - 비밀번호 그냥 엔터
sudo mysql -u root -p

# 데이터베이스 생성, 사용자 설정
ALTER USER 'root'@'localhost' IDENTIFIED BY '1111';
CREATE DATABASE test;

# 귀찮아서 비밀번호 단순하게 바꾸기 - 원래는 이러면 안되고...
SET GLOBAL validate_password.policy=LOW;
SET GLOBAL validate_password.length=4;

# root 외부 접속 권한 부여
CREATE USER 'root'@'%' IDENTIFIED BY '1111';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

exit

# 앱 서버-------------------------------------------
# Flask 5000 포트 열기 - INPUT 5 이하로 해야 열리더라...
sudo iptables -I INPUT 1 -p tcp --dport 5000 -j ACCEPT
sudo netfilter-persistent save

# MySQL 설치
sudo apt update
sudo apt install mysql-client -y

# MySQL 설치 확인
mysql --version

# python 명령어 설정하고 확인
sudo apt install python-is-python3
python --version

# 파이썬 가상환경 구성
mkdir venvs
cd venvs
sudo apt install python3.12-venv
python -m venv ocisampleweb
cd ocisampleweb/bin
source activate

# 가상환경을 alias로 등록
echo "alias ocisampleweb='cd /home/ubuntu/venvs/ocisampleweb/;source /home/ubuntu/venvs/ocisampleweb/bin/activate'" >> ~/.bashrc
source ~/.bashrc
deactivate
ocisampleweb

# Flask와 관련 패키지 설치
pip install --upgrade pip
pip install flask
pip install pymysql
pip install faker

# hello.py 작성

# 앱 실행
export FLASK_APP=hello
flask run --host=0.0.0.0
