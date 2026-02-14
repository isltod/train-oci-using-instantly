# snapd와 snapd core 설치
sudo apt update
sudo apt install snapd -y

sudo snap install core
sudo snap refresh core

# certbot 설치
sudo snap install certbot --classic
certbot --version

# 인증 - 질문에 답해야 함
sudo certbot --nginx -d seedlibrary.net -d www.seedlibrary.net

# Certificate is saved at: /etc/letsencrypt/live/seedlibrary.net/fullchain.pem
# Key is saved at:         /etc/letsencrypt/live/seedlibrary.net/privkey.pem
# This certificate expires on 2026-05-14.
# Successfully deployed certificate for seedlibrary.net to /etc/nginx/sites-enabled/seedlibrary.net
# Successfully deployed certificate for www.seedlibrary.net to /etc/nginx/sites-enabled/seedlibrary.net

# 생성한 인증서와 디렉터리 확인
sudo certbot certificates
ll /etc/letsencrypt/renewal/

# 인증서 갱신을 위한 타이버 확인
sudo systemctl list-timers | grep certbot
sudo systemctl cat snap.certbot.renew.timer
sudo systemctl cat snap.certbot.renew.service

# 삭제 - 이건 어떻게 하는지...
#sudo certbot delete --cert-name seedlibrary.net