# 1. 없으면 설치 - 패키지 업데이트 및 Nginx 설치
sudo apt update
sudo apt install nginx -y

# 2. 웹사이트 파일을 저장할 디렉토리 생성
sudo mkdir -p /var/www/://seedlibrary.net

# 3. 디렉토리 권한 설정 (현재 사용자)
sudo chown -R $USER:$USER /var/www/://seedlibrary.net

# 4. 간단한 index.html 파일 만들어 넣기
cp index.html /var/www/://seedlibrary.net/

# 도메인 홈페이지 하위 서비스 설정
sudo vim /etc/nginx/sites-available/seedlibrary.net
# seedlibrary.net 내용 붙여넣기..기존 3000번 포트로 서비스 되고 있는 seed-sharing-2026 하위로 설정

# 링크 걸고
sudo ln -s /etc/nginx/sites-available/seedlibrary.net /etc/nginx/sites-enabled/

# 문법 확인하고
sudo nginx -t

# 다시시작
sudo systemctl restart nginx
