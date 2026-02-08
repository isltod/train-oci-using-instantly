# 앱 & 디비 서버 ---------------------------------
# 오토스케일링 때문에 책과는 다르게 한 대에 앱 디비 모두 설치하고 복제...
# 라고 했는데...다 필요없네...이놈들이 이것도 막아놨네...슬그머니...

# MySQL 3306 포트 열기
sudo iptables -I INPUT -p tcp --dport 5000 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 3306 -j ACCEPT
sudo netfilter-persistent save

# 지울 때는
#sudo iptables -L INPUT -n --line-numbers
#sudo iptables -D INPUT 2

# python 명령어 설정하고 확인
sudo apt update
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
# pip install pymysql - 이건 deprecated
pip install mysql-connector-python
pip install faker

# hello.py 작성

# 앱 실행
export FLASK_APP=hello
flask run --host=0.0.0.0
# 로컬에서 http://168.107.57.198:5000/ 확인

# MySQL 설치
sudo apt install mysql-server -y
# 클라이언트만 설치할 때는 아래...
#sudo apt install mysql-client -y

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

# 이건 위에 sudo mysql_secure_installation과 연동
#귀찮아서 비밀번호 단순하게 바꾸기 - 원래는 이러면 안되고...
SET GLOBAL validate_password.policy=LOW;
SET GLOBAL validate_password.length=4;

# root 외부 접속 권한 부여
CREATE USER 'root'@'%' IDENTIFIED BY '1111';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
exit

# 외부 클라이언트 접속 허가
sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf
# bind-address = 0.0.0.0
# mysqlx-bind-address = 0.0.0.0
sudo service mysql restart

# mysql_schema.sql 작성

# DB 스키마 추가
mysql --host=10.0.0.170 test -u root -p < mysql_schema.sql

# sample-monolith.py 작성

# monolith db 연동 앱 실행
export FLASK_APP=sample-monolith
flask run --host=0.0.0.0
# 로컬에서 http://168.107.57.198:5000/, http://168.107.57.198:5000/hello 확인

# monolith 서비스 파일 작성
sudo vim /etc/systemd/system/sample-monolith.service

# monolith 서비스 등록
sudo systemctl daemon-reload
sudo systemctl enable sample-monolith.service
sudo systemctl start sample-monolith.service
sudo systemctl status sample-monolith.service

# CA 생성을 위해서는 아래 권한 추가해야 한다고...
#Allow any-user to use keys in tenancy where request.principal.type='certificateauthority'
#Allow any-user to manage objects in tenancy where request.principal.type='certificateauthority'

# dynamic group 생성을 위해서는 compartment ocid를 복사해서 Rule 추가
#ocid1.compartment.oc1..aaaaaaaaj7b2upk6lw66pke4jwqa2mznhesfn6zghssir2ixxpjbm7hp2jia
#All {instance.compartment.id ='ocid1.compartment.oc1..aaaaaaaaj7b2upk6lw66pke4jwqa2mznhesfn6zghssir2ixxpjbm7hp2jia'}

# 오토스케일링 위해서는 정책에 다음 추가
#Allow dynamic-group oci-demo-dyngroup to manage compute-management-family in compartment ociexplained
#Allow dynamic-group oci-demo-dyngroup to manage object-family in compartment ociexplained
#Allow dynamic-group oci-demo-dyngroup to manage auto-scaling-configurations in compartment ociexplained

# OCI Cloud Shell 삭제 명령
# 오토스케일링
oci autoscaling configuration list -c $COMP_ID --query 'data[*].{name:"name", id:"id"}' --output table
oci autoscaling configuration delete --force --auto-scaling-configuration-id "ocidl.autoscalingconfiguration.oci.ap-chuncheon-1.aaaaaaaavyay22tyqvdhiyocdgs5o4t6k5dini2skavk7npwk4irfzh326va"
# 인스턴스 풀
oci compute-management instance-pool list -c $COMP_ID --query 'data[*].{name:"name", id:"id"}' --output table
oci compute-management instance-pool terminate --force --instance-pool-id "ocidl.instancepool.oci.ap-chuncheon-1.amailarqadacaeada3wrecqo24t7icj3aoioinbckaoyduvosed4kbaxgtf3q"
# 로드밸런서
oci lb load-balancer list -c $COMP_ID --query 'data[*].{name:"name", id:"id"}' --output table
oci lb load-balancer delete --force --load-balancer-id "ocid1.loadbalancer.oc1.ap-chuncheon-1.aaaaaaaat7tmh2ab4o2pl5siglnzwleevtmmounzd7erdagz3im3pffh7fkq"
# 가상머신
oci compute instance list -c $COMP_ID --query 'data[*].{name:"name", id:"id"}' --output table
oci compute instance terminate --force --instance-id "ocid1.instance.oc1.ap-chuncheon-1.an4w4ljrtguxr4ackdxb7pltec7hgphghfiicco5rbumf7wx2jsps43jjdeq"
oci compute instance terminate --force --instance-id "ocid1.instance.oc1.ap-chuncheon-1.an4w4ljrtguxr4acp2svdxnrt7dv7qyt4tao2o37aeeubgp23g56ykd3ghsa"
oci compute instance terminate --force --instance-id "ocid1.instance.oc1.ap-chuncheon-1.an4w4ljrtguxr4acspvbbrh7konw6pjwyb34u6fmvw3obbl5urtdod6jju2q"
oci compute instance terminate --force --instance-id "ocid1.instance.oc1.ap-chuncheon-1.an4w4ljrtguxr4ack5h54wc5qyiezrufuoxashiigp6i6734dipuvdjedeeq"
# 배스천
oci bastion bastion list -c $COMP_ID --query 'data[*].{name:"name", id:"id"}' --output table
oci bastion bastion delete --force --bastion-id "ocid1.bastion.oc1.ap-chuncheon-1.amaaaaaatguxr4aay3jfnlgqs2f452knw2ihcdvx7xrp7qknkrtuq7khtlzq"