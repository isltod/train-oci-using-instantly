# pm2 설치
sudo npm install -g pm2
# 앱 실행
pm2 start npm -- start
# 부팅시 자동 실행 설정
pm2 startup
pm2 save

PM2 자동 실행 해제
pm2 unstartup
표시된 명령 복사해서 붙여넣기
pm2 delete all
pm2 save
아래는 선택
sudo systemctl stop pm2-root.service  # 또는 pm2-사용자명.service
sudo systemctl disable pm2-root.service
sudo rm /etc/systemd/system/pm2-root.service
sudo systemctl daemon-reload
