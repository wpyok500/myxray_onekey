# 安装nginx 最新版本
source '/etc/os-release'
#nginx 必装依赖库
sudo apt install curl gnupg2 ca-certificates lsb-release ubuntu-keyring
#设置nginx 版本
#https://www.nginx.com/resources/wiki/start/topics/tutorials/install/
#$(lsb_release -cs)两种编译Codename（bionic xenial）  #  Codename（bionic xenial）请查阅对应nginx编译版本代号：http://nginx.org/en/linux_packages.html#stable
echo "deb http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" >/etc/apt/sources.list.d/nginx.list
curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
#更新包
apt update
#安装nginx
apt-get install -y nginx

# 稳定版本 配置
#!/bin/bash
cat > /etc/nginx/conf.d/default.conf <<-EOF
deb https://nginx.org/packages/ubuntu/ $release nginx
deb-src https://nginx.org/packages/ubuntu/ $release nginx
EOF

# 卸载nginx
apt-get autoremove nginx -y && rm -f /etc/apt/sources.list.d/nginx.list 

# 卸载openssl
apt-get autoremove  openssl -y && rm -rf ssl

# 卸载acme
 /root/.acme.sh/acme.sh --uninstall &&  rm -rf /root/.acme.sh
