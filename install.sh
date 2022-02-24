#!/bin/bash
# 在此处自定义配置
PORT=${PORT:-443}
AUUID=${AUUID:-24b4b1e1-7a89-45f6-858c-242cf53b5bdb}
ParameterSSENCYPT=${ParameterSSENCYPT:-chacha20-ietf-poly1305}
CADDYIndexPage=${CADDYIndexPage:-https://codeload.github.com/ripienaar/free-for-dev/zip/master}
CERT_PATH=${CERT_PATH:-/root/.cert/cert.pem}
KEY_PATH=${CERT_PATH:-/root/.cert/key.pem}

# download execution
wget "https://caddyserver.com/api/download?os=linux&arch=amd64" -O caddy
wget "https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip" -O xray-linux-64.zip
unzip -o xray-linux-64.zip && rm -rf xray-linux-64.zip
chmod +x caddy xray startvrush && mv caddy xray startvrush -t /usr/bin/
mv geoip.dat  geosite.dat -t /usr/bin/

# set caddy
mkdir -p /etc/caddy/ /etc/xray/ /usr/share/caddy
echo -e "User-agent: *\nDisallow: /" > /usr/share/caddy/robots.txt
wget $CADDYIndexPage -O /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/


# set config file
cat Caddyfile | sed -e "1c :$PORT" -e "s/\$AUUID/$AUUID/g" -e "s/\$CERT_PATH/$CERT_PATH/g" -e "s/\$KEY_PATH/$KEY_PATH/g" -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $AUUID)/g" > /etc/caddy/Caddyfile
cat config.json | sed -e "s/\$AUUID/$AUUID/g" -e "s/\$ParameterSSENCYPT/$ParameterSSENCYPT/g" > /etc/xray/xray.json

# add service
mv xray.service caddy.service -t /lib/systemd/system/
systemctl enable xray.service
systemctl enable caddy.service

# clean 
cd .. && rm -rf vrushForHax
