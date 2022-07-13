# 依赖库

apt-get update -y && apt install -y jq openssl cron socat curl unzip vim tar

apt-get update -y && apt install curl gnupg2 ca-certificates lsb-release ubuntu-keyring

# 安装nginx 最新版本

source '/etc/os-release'

#nginx 必装依赖库

apt-get update -y && apt install curl gnupg2 ca-certificates lsb-release ubuntu-keyring

#设置nginx 版本

#https://www.nginx.com/resources/wiki/start/topics/tutorials/install/

#$(lsb_release -cs)两种编译Codename（bionic xenial） 

#Codename（bionic xenial）请查阅对应nginx编译版本代号：http://nginx.org/en/linux_packages.html#stable

#echo "deb http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" >/etc/apt/sources.list.d/nginx.list

echo "deb https://nginx.org/packages/ubuntu/ $(lsb_release -cs) nginx" >/etc/apt/sources.list.d/nginx.list

sed -i "\$a deb-src https://nginx.org/packages/ubuntu/ $(lsb_release -cs) nginx" /etc/apt/sources.list.d/nginx.list

curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -

#更新包并安装安装nginx

apt-get update -y && apt-get install -y nginx


# 稳定版本 配置
#!/bin/bash
cat > /etc/nginx/conf.d/default.conf <<-EOF
deb https://nginx.org/packages/ubuntu/ $release nginx
deb-src https://nginx.org/packages/ubuntu/ $release nginx
EOF

# acme安装
```
ssl_cert_dir="/etc/ssl/private"
curl https://get.acme.sh | sh && ~/.acme.sh/acme.sh --upgrade --auto-upgrade
~/.acme.sh/acme.sh --set-default-ca --server zerossl #Letsencrypt.ort BuyPass.com
~/.acme.sh/acme.sh --register-account -m ${mymail}
~/.acme.sh/acme.sh --issue -d ${domain} --standalone -k ec-256 --force #webroot
#~/.acme.sh/acme.sh --install-cert -d ${domain} --fullchain-file $ssl_cert_dir/fullchain.cer --key-file $ssl_cert_dir/private.key --ecc
cp -r /root/.acme.sh/${domain}_ecc/*.* $ssl_cert_dir
set_nobody_certificate $ssl_cert_dir

ssl_cert_dir="/etc/ssl/private" 
cert_group="nogroup"
function set_nobody_certificate() {
	for file in $1/*
	do
		if [ -d "$file" ]
		then 
		  #echo "$file is directory"
		  echo ""
		elif [ -f "$file" ]
		then
		  #echo "$file is file"
			if [[ $file == *".cer"* || $file == *".pem"* || $file == *".crt"*  || $file == *".key"* ]]
			then
			    #echo "$file包含"
			    chown nobody.$cert_group $file
			fi
		fi
	done
}

```

# 卸载nginx
apt-get autoremove nginx -y && apt-get purge nginx -y  && rm -f /etc/apt/sources.list.d/nginx.list 

# 卸载openssl
apt-get autoremove  openssl -y && apt-get purge openssl -y && rm -rf ssl

# 卸载acme
 /root/.acme.sh/acme.sh --uninstall &&  rm -rf /root/.acme.sh
 
 # 常用命令
 ```
 nginx -s reload &&  systemctl restart nginx && systemctl status nginx
 ```
 ```
 function modify_uuid() {
	UUID=$(cat /proc/sys/kernel/random/uuid)
	sed -i 's/"id": ""/"id": "'${UUID}'"/g'  $xray_conf_dir/config.json
	echo  -e "${Blue}UUID更改完成${EndColor}"
	xray_link
}
```
xray_conf_dir="/usr/local/etc/xray"

cronpath="/var/spool/cron/crontabs"

/etc/nginx/conf.d/default.conf

xray run /usr/local/etc/xray/config.json

systemctl status xray

bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --version 1.5.8
```
installed: /usr/local/bin/xray

installed: /etc/systemd/system/xray.service
installed: /etc/systemd/system/xray@.service

installed: /usr/local/bin/xray
installed: /usr/local/etc/xray/*.json

installed: /usr/local/share/xray/geoip.dat
installed: /usr/local/share/xray/geosite.dat

installed: /var/log/xray/access.log
installed: /var/log/xray/error.log

```
# 获取xray最新版本
```
# 下载xray_releases  json文档
wget -N --no-check-certificate -q "https://api.github.com/repos/XTLS/Xray-core/releases" -O xray_releases  && chmod  777 xray_releases
#获取最新版本
tmp_file=xray_releases && releases_list=($(sed 'y/,/\n/' "$tmp_file" | grep 'tag_name' | awk -F '"' '{print $4}')) && echo  ${releases_list[0]/v/}

#获取xray当前版本
current_version="$(/usr/local/bin/xray -version | awk 'NR==1 {print $2}')" && echo ${current_version}
```
