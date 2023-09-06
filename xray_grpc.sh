#!/bin/bash
#====================================================
#	System Request:Ubuntu 16.04+
#	Author:	福建-兮
#	Dscription: Xray onekey Management
#	email: wpyok500@gmail.com
#====================================================
ssl_cert_dir="/etc/ssl/private"
cert_group="nogroup"
Green="\033[32m"
Red="\033[31m"
Blue="\033[34m"
Purple="\033[35m"
EndColor="\033[0m"
cronpath="/var/spool/cron/crontabs"
isins=0 #是否检查系统
isnginx=0 #是否重启nginx
shell_version="1.1.8"
current_version=""
last_version=""
xray_conf_dir="/usr/local/etc/xray"
nginx_conf="/etc/nginx/conf.d/default.conf"
xrayport="2002"

function print_ok() {
  echo -e "${Blue}$1${EndColor}"
}

function change_web() {
  web_link="https://raw.githubusercontent.com/wpyok500/myxray_onekey/main/3DCEList.zip"
  read -rp "伪装站点：1、元素周期表；2、计算器；" web_num
  case $web_num in
  1)
    web_link="https://raw.githubusercontent.com/wpyok500/myxray_onekey/main/3DCEList.zip"
    ;;
  2)
    web_link="https://raw.githubusercontent.com/wpyok500/myxray_onekey/main/jsq.zip"
    ;;
  *)
    echo -e "${Red}输入错误，退出${EndColor}"
    exit 1
    ;;
  esac
  rm -rf /www/xray_web
  if [ ! -d "/www" ]; then
  mkdir /www
  fi
  if [ ! -d "/www/xray_web" ]; then
  mkdir /www/xray_web
  fi
  wget --no-check-certificate -c  -O /www/xray_web/web.zip $web_link
  unzip -d /www/xray_web /www/xray_web/web.zip
  rm -rf /www/xray_web/web.zip
  echo -e  "${Blue}伪装站点更换完成${EndColor}"
}



function install_nginx() {
  #echo -e "${Red}需要先安装xray，否则可能出现不可意料的错误${EndColor}"
  #sleep 5
  if [ $isins == 0 ]
  then
  	system_check
  fi
  nginx_install
  #apt-get install nginx -y
  $INS install nginx -y
  echo -e  "${Blue}nginx已安装完成${EndColor}"
  rm -rf /www/xray_web
  if [ ! -d "/www" ]; then
  mkdir /www
  fi
  if [ ! -d "/www/xray_web" ]; then
  mkdir /www/xray_web
  fi
  web_link="https://raw.githubusercontent.com/wpyok500/myxray_onekey/main/3DCEList.zip"
  read -rp "伪装站点：1、元素周期表；2、计算器；" web_num
  case $web_num in
  1)
    web_link="https://raw.githubusercontent.com/wpyok500/myxray_onekey/main/3DCEList.zip"
    ;;
  2)
    web_link="https://raw.githubusercontent.com/wpyok500/myxray_onekey/main/jsq.zip"
    ;;
  *)
    echo -e "${Red}输入错误，将使用元素周期表伪装站点${EndColor}"
    ;;
  esac
  sed -i 's/root   \/usr\/share\/nginx\/html/root   \/www\/xray_web/g' ${nginx_conf}
  sed -i 's/index  index.html index.htm/index index.php index.html index.htm default.php default.htm default.html/g' ${nginx_conf}
  wget --no-check-certificate -c  -O /www/xray_web/web.zip $web_link
  unzip -d /www/xray_web /www/xray_web/web.zip
  rm -rf /www/xray_web/web.zip
  systemctl start nginx && systemctl restart nginx
  echo -e  "${Blue}伪装站点完成${EndColor}"
}

function nginxdefultconf() {
rm -rf ${nginx_conf}
	cat > ${nginx_conf} <<-EOF
server
{
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    #配置站点域名，多个以空格分开
    server_name _;
    index index.php index.html index.htm default.php default.htm default.html;
    root /www/xray_web;
    charset utf-8;
    
    add_header Strict-Transport-Security "max-age=63072000" always;
    
    #禁止访问的文件或目录
    location ~ ^/(\.user.ini|\.htaccess|\.git|\.svn|\.project|LICENSE|README.md)
    {
        return 404;
    }
    
    location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
    {
        expires      30d;
        error_log /dev/null;
        access_log /dev/null;
    }
    
    location ~ .*\.(js|css)?$
    {
        expires      12h;
        error_log /dev/null;
        access_log /dev/null; 
    }
    location ^~ /$rootpath {
	    proxy_pass http://127.0.0.1:$xuiPORT/$rootpath;
	    proxy_set_header Host \$host;
	    proxy_set_header X-Real-IP \$remote_addr;
	    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF
}

function firewall_GL() {
	if [[ $(dpkg -l | grep -w firewalld) ]];
	then
		firewall_GL1
	else
		echo -e "${Red}系统未安装firwalld防火墙${EndColor}"
	     exit 1
	fi
}

function firewall_GL1() {
	echo -e "${Green}1.  开启端口"
	echo -e "${Green}2.  关闭端口"
	read -rp "请输入数字：" menu_fwnum
	  case $menu_fwnum in
	  1)
	  #网站访问反代端口开启设置等
         read -rp "请输入端口号(默认：54991)：" PORT
	    [ -z "$PORT" ] && PORT="54991"
	    if [[ $PORT -le 0 ]] || [[ $PORT -gt 65535 ]]; then
	      echo "请输入 0-65535 之间的值"
	      exit 1
	    fi
	    port_exist_check $PORT
	    firewall-cmd --zone=public --add-port=$PORT/tcp --permanent && firewall-cmd --reload
	    systemctl restart firewalld.service #systemctl start firewalld.service
	    firewall-cmd --list-all
	    ;;
	  2)
	    read -rp "请输入即将关闭端口号(默认：0)：" PORT
	    [ -z "$PORT" ] && PORT="0"
	    if [[ $PORT -le 0 ]] || [[ $PORT -gt 65535 ]]; then
	      echo "请输入 0-65535 之间的值"
	      exit 1
	    fi
	    port_exist_check $PORT
	    firewall-cmd --zone=public --remove-port=$PORT/tcp --permanent && firewall-cmd --reload
	    systemctl restart firewalld.service #systemctl start firewalld.service
	    firewall-cmd --list-all
	    ;;
	  *)
	    echo -e "${Red}请输入正确的数字${EndColor}"
	    ;;
	  esac
}

function firewall_install() {
	echo -e "${Blue}是否安装firwalld防火墙 [Y/N]?${EndColor}"
		  read -r restart_firewalld
		  #read -rp "是否重新开启firwalld防火墙 [Y/N]：" restart_firewalld
		  #[ -z "$restart_firewalld" ] && restart_firewalld="N"
		  case $restart_firewalld in
		  [yY][eE][sS] | [yY])
		    if [ $isins == 0 ] 
			then
		  	  system_check
		     fi
			$INS install -y firewalld
			echo -e  "${Red}请确保本次输入的x-ui面板端口与x-ui安装时的面板端口保持一致${EndColor}"
			read -rp "请输入面板端口号(默认：54321)：" x_ui_PORT
      [ -z "$x_ui_PORT" ] && x_ui_PORT="54321"
      if [[ $x_ui_PORT -le 0 ]] || [[ $x_ui_PORT -gt 65535 ]]; then
        echo "请输入 0-65535 之间的值"
        exit 1
      fi
			firewall-cmd --zone=public --add-port=80/tcp --permanent && firewall-cmd --zone=public --add-port=443/tcp --permanent && firewall-cmd --zone=public --add-port=${x_ui_PORT}/tcp --permanent && firewall-cmd --reload
			systemctl restart firewalld.service #systemctl start firewalld.service
			firewall-cmd --list-all
			echo -e "${Blue}安装防火墙并开启80、443、${x_ui_PORT}端口${EndColor}"
		    ;;
		  *) ;;
		  esac
	
	#卸载防火墙 apt purge firewalld
}

function isfirewalld() {
	if [[ $(dpkg -l | grep -w firewalld) ]];
	then
		  echo -e "${Blue}是否重新开启firwalld防火墙 [Y/N]?${EndColor}"
		  read -r restart_firewalld
		  #read -rp "是否重新开启firwalld防火墙 [Y/N]：" restart_firewalld
		  #[ -z "$restart_firewalld" ] && restart_firewalld="N"
		  case $restart_firewalld in
		  [yY][eE][sS] | [yY])
		    systemctl start firewalld
		    firewall-cmd --state
		    ;;
		  *) ;;
		  esac
	fi
}

function update_sh() {
  ol_version=$(curl -L -s https://raw.githubusercontent.com/wpyok500/myxray_onekey/main/xray_grpc.sh | grep "shell_version=" | head -1 | awk -F '=|"' '{print $3}')
  echo -e "Github脚本版本号：${ol_version}"
  echo -e "本地脚本版本号：${shell_version}"
  if [[ "$shell_version" != "$(echo -e "$shell_version\n$ol_version" | sort -rV | head -1)" ]]; then
    print_ok "存在新版本，是否更新 [Y/N]?"
    read -r update_confirm
    case $update_confirm in
    [yY][eE][sS] | [yY])
      wget -N --no-check-certificate -q "https://raw.githubusercontent.com/wpyok500/myxray_onekey/main/xray_grpc.sh" && chmod +x myxui.sh
      echo -e "${Blue}更新完成${EndColor}"
      #echo -e "您可以通过 bash $0 执行本程序"
      bash $0
      exit 0
      ;;
    *) ;;
    esac
  else
    echo -e "${Blue}当前版本为最新版本${EndColor}"
    #echo -e "您可以通过 bash $0 执行本程序"
    bash $0
  fi
}

function manual_certificate() {
	DOMAIN=$(cat ${ssl_cert_dir}/domain)
	port_exist_check 80
	~/.acme.sh/acme.sh --issue -d ${DOMAIN} --standalone -k ec-256 --force
	echo -e  "${Blue}SSL证书获取完成${EndColor}"
	#~/.acme.sh/acme.sh --install-cert -d ${domain} --fullchain-file $ssl_cert_dir/fullchain.cer --key-file $ssl_cert_dir/private.key --ecc
	cp -r /root/.acme.sh/${DOMAIN}_ecc/*.* $ssl_cert_dir
	set_nobody_certificate $ssl_cert_dir
	echo -e  "${Blue}SSL 证书配置到 $ssl_cert_dir${EndColor}"
}




function bbrjiashu(){
	wget -N --no-check-certificate "https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
}

function remove_xui() {
	bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove
	chmod 777 /usr/local/etc
	rm -rf /usr/local/etc
	remove_n_a
}

function remove_n_a() {
  echo  "是否卸载nginx [Y/N]?"
  read -r uninstall_nginx
  case $uninstall_nginx in
  [yY][eE][sS] | [yY])
    if [[ "${ID}" == "centos" || "${ID}" == "ol" ]]; then
      yum remove nginx -y
    else
      #apt-get remove nginx nginx-common nginx-full
      apt purge nginx -y
    fi
    ;;
  *) ;;
  esac
  echo  "是否卸载acme.sh [Y/N]?"
  read -r uninstall_acme
  case $uninstall_acme in
  [yY][eE][sS] | [yY])
    /root/.acme.sh/acme.sh --uninstall
    rm -rf /root/.acme.sh
    delautogetssl
    ;;
  *) ;;
  esac
  print_ok "卸载完成"
  exit 0
}

function delautogetssl() {
    #sed -i '/auto_ssl/d' /var/spool/cron/crontabs/root
    rm -rf $ssl_cert_dir/auto_ssl.sh
    rm -rf $ssl_cert_dir/auto_up_xray.sh
    sed -i '/auto_ssl/d' $cronpath/root
    sed -i '/geoip.dat/d' $cronpath/root
    sed -i '/geosite.dat/d' $cronpath/root
    sed -i '/auto_up_xray/d' $cronpath/root
    sed -i '/install-geodata/d' $cronpath/root
    #cat $cronpath/root | while read line
    #do
    #	 if [[ $line == *"autogetssl"* ]]; then
    #	   sed '/autogetssl/d' $cronpath/root
    #	 fi
   # done
}

function port_exist_check() {
  if [[ 0 -eq $(lsof -i:"$1" | grep -i -c "listen") ]]; then
    print_ok "$1 端口未被占用"
    sleep 1
  else
    echo -e  "${Red}检测到 $1 端口被占用，以下为 $1 端口占用信息${EndColor}"
    lsof -i:"$1"
    echo -e  "${Red}5s 后将尝试自动 kill 占用进程${EndColor}"
    sleep 5
    if [[ $(lsof -i:"$1" | awk '{print $1}' | grep "nginx") ]]; then
      #echo "nginx"
      isnginx=1
    fi
    #tp=$(lsof -i:80 | awk '{print $1}' | grep "nginx")
    lsof -i:"$1" | awk '{print $2}' | grep -v "PID" | xargs kill -9
    print_ok "kill 完成"
    sleep 1
  fi
}

function update_geoip() {
   #wget -N --no-check-certificate -q -O /usr/local/x-ui/bin/geoip.dat "https://github.com/v2fly/geoip/releases/latest/download/geoip.dat"
   #wget -N --no-check-certificate -q -O /usr/local/x-ui/bin/geosite.dat "https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat"
   wget -N --no-check-certificate -q -O /usr/local/share/xray/geoip.dat "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
   wget -N --no-check-certificate -q -O /usr/local/share/xray/geosite.dat "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
   set_crontab "geoip.dat" 'wget -N --no-check-certificate -q -O /usr/local/share/xray/geoip.dat "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"'
   set_crontab "geosite.dat" 'wget -N --no-check-certificate -q -O /usr/local/share/xray/geosite.dat "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"'
   echo -e  "${Blue}geoip、geosite数据更新完成${EndColor}"
}

function set_crontab() {
  flay=0
  #export res=$(echo $str1  |  grep $str2)
  while read -r line
  do
     res=$(echo $line  |  grep "$1")
     #echo $res
	if [[ $res == "" ]]; then
	    flay=1
	else
	    flay=0
	    break
	fi
  done </var/spool/cron/crontabs/root
  if [[ $flay == 1 ]]; then
	sudo sed -i "\$a0 1 */5 * * $2" $cronpath/root
  fi
}

function is_root() {
  if [[ 0 == "$UID" ]]; then
    echo -e  "${Blue}当前用户是 root 用户，开始安装流程${EndColor}"
  else
    echo -e  "${Red}当前用户不是 root 用户，请切换到 root 用户后重新执行脚本${EndColor}"
    exit 1
  fi
}

# 检查系统
function check_system()
{
  source '/etc/os-release'
  if [[ "${ID}" == "centos" && ${VERSION_ID} -ge 7 ]]; then
    echo -e  "当前系统为 Centos ${VERSION_ID} ${VERSION}${EndColor}"
    INS="yum"
  elif [[ "${ID}" == "ol" ]]; then
    echo -e  "当前系统为 Oracle Linux ${VERSION_ID} ${VERSION}${EndColor}"
    INS="yum"
  elif [[ "${ID}" == "debian" && ${VERSION_ID} -ge 9 ]]; then
    echo -e  "当前系统为 Debian ${VERSION_ID} ${VERSION}${EndColor}"
    INS="apt"
  elif [[ "${ID}" == "ubuntu" && $(echo "${VERSION_ID}" | cut -d '.' -f1) -ge 16 ]]; then
    echo -e  "${Blue}当前系统为 Ubuntu ${VERSION_ID} ${UBUNTU_CODENAME}${EndColor}"
    INS="apt-get"
  else
    echo -e  "${Red}当前系统为 ${ID} ${VERSION_ID} 不在支持的系统列表内${EndColor}"
    exit 1
  fi
}

function system_check() {
  source '/etc/os-release'
  if [[ "${ID}" == "centos" && ${VERSION_ID} -ge 7 ]]; then
    echo -e  "当前系统为 Centos ${VERSION_ID} ${VERSION}${EndColor}"
    INS="yum"
  elif [[ "${ID}" == "ol" ]]; then
    echo -e  "当前系统为 Oracle Linux ${VERSION_ID} ${VERSION}${EndColor}"
    INS="yum"
  elif [[ "${ID}" == "debian" && ${VERSION_ID} -ge 9 ]]; then
    echo -e  "当前系统为 Debian ${VERSION_ID} ${VERSION}${EndColor}"
    INS="apt"
    # 清除可能的遗留问题
    rm -f /etc/apt/sources.list.d/nginx.list
    $INS install -y curl gnupg2 ca-certificates lsb-release
    echo "deb http://nginx.org/packages/debian $(lsb_release -cs) nginx" >/etc/apt/sources.list.d/nginx.list
    curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
    apt update
  elif [[ "${ID}" == "ubuntu" && $(echo "${VERSION_ID}" | cut -d '.' -f1) -ge 16 ]]; then
    echo -e  "${Blue}当前系统为 Ubuntu ${VERSION_ID} ${UBUNTU_CODENAME}${EndColor}"
    INS="apt-get"
    # 清除可能的遗留问题
    rm -f /etc/apt/sources.list.d/nginx.list
    $INS install -y curl gnupg2 ca-certificates lsb-release
    #https://www.nginx.com/resources/wiki/start/topics/tutorials/install/
    #$(lsb_release -cs)两种编译Codename（bionic xenial）  #  Codename（bionic xenial）请查阅对应nginx编译版本代号：http://nginx.org/en/linux_packages.html#stable
    echo "deb http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" >/etc/apt/sources.list.d/nginx.list
    curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
    apt update
  else
    echo -e  "${Red}当前系统为 ${ID} ${VERSION_ID} 不在支持的系统列表内${EndColor}"
    exit 1
  fi

  if [[ $(grep "nogroup" /etc/group) ]]; then
    cert_group="nogroup"
  fi
  #D-Bus是一种高级的进程间通信机制
  $INS  install -y dbus
  # 关闭各类防火墙
  systemctl stop firewalld
  systemctl disable firewalld
  systemctl stop nftables
  systemctl disable nftables
  systemctl stop ufw
  systemctl disable ufw
}

function domain_check() {
  echo -e "${Red}如果开启了CF CDN代理请先关闭，脚本安装完后在开启${EndColor}"
  read -rp "请输入你的域名信息(eg: ozx2flay.tk):" domain
  domain_ip=$(ping "${domain}" -c 1 | sed '1{s/[^(]*(//;s/).*//;q}')
  echo  -e "${Blue}正在获取 IP 地址信息，请耐心等待${EndColor}"
  local_ip=$(curl -4L api64.ipify.org)
  echo -e "${Blue}域名通过 DNS 解析的 IP 地址：${domain_ip}${EndColor}"
  echo -e "${Blue}本机公网 IP 地址： ${local_ip}${EndColor}"
  sleep 2
  if [[ ${domain_ip} == "${local_ip}" ]]; then
    echo  -e "${Blue}域名通过 DNS 解析的 IP 地址与 本机 IP 地址匹配${EndColor}"
    sleep 2
  else
    echo -e  "${Red}请确保域名添加了正确的 A 记录，否则将无法正常使用 xray${EndColor}"
    echo -e  "${Red}域名通过 DNS 解析的 IP 地址与 本机 IP 地址不匹配，是否继续安装？（y/n）${EndColor}" && read -r install
    case $install in
    [yY][eE][sS] | [yY])
      echo "继续安装"
      sleep 2
      ;;
    *)
      echo -e "${Red}安装终止${EndColor}"
      exit 2
      ;;
    esac
  fi
}

function install_acme()
{
  echo -e  "${Blue}依赖库安装完成${EndColor}"
	curl https://get.acme.sh | sh && ~/.acme.sh/acme.sh --upgrade --auto-upgrade
	echo -e  "${Blue}SSL证书生成依赖库安装完成${EndColor}"
	domain_check
	echo $domain >$ssl_cert_dir/domain #记录域名
	#cat > $ssl_cert_dir/domain <<-EOF
	#$domain
	#EOF
	~/.acme.sh/acme.sh --set-default-ca --server zerossl #Letsencrypt.ort BuyPass.com
	read -rp "请输入你的邮箱信息(eg: mymail@gmail.com):" mymail
	~/.acme.sh/acme.sh --register-account -m ${mymail}
	~/.acme.sh/acme.sh --issue -d ${domain} --standalone -k ec-256 --force #webroot
	echo -e  "${Blue}SSL证书获取完成${EndColor}"
	#~/.acme.sh/acme.sh --install-cert -d ${domain} --fullchain-file $ssl_cert_dir/fullchain.cer --key-file $ssl_cert_dir/private.key --ecc
	cp -r /root/.acme.sh/${domain}_ecc/*.* $ssl_cert_dir
	echo -e  "${Blue}SSL 证书配置到 $ssl_cert_dir${EndColor}"
	set_nobody_certificate $ssl_cert_dir 
}

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

function autoGetSSL() {
  DOMAIN=$(cat ${ssl_cert_dir}/domain)
  rm -rf $ssl_cert_dir/auto_ssl.sh
  
  cat > $ssl_cert_dir/auto_ssl.sh <<-EOF
#!/bin/bash
cert_group="nogroup"
ssl_cert_dir="/etc/ssl/private"
function set_nobody_certificate() {
	for file in \$1/*
	do
		if [ -d "\$file" ]
		then 
		  #echo "$file is directory"
		  echo ""
		elif [ -f "\$file" ]
		then
		  #echo "$file is file"
			if [[ \$file == *".cer"* || \$file == *".pem"* || \$file == *".crt"*  || \$file == *".key"* ]]
			then
			    #echo "$file包含"
			    chown nobody.$cert_group \$file
			fi
		fi
	done
}

function port_exist_check() {
  if [[ 0 -eq \$(lsof -i:"\$1" | grep -i -c "listen") ]]; then
    echo -e "\033[34m$1 端口未被占用\033[0m"
    sleep 1
  else
    echo -e  "${Red}检测到 \$1 端口被占用，以下为 \$1 端口占用信息${EndColor}"
    lsof -i:"\$1"
    echo -e  "${Red}5s 后将尝试自动 kill 占用进程${EndColor}"
    sleep 5
    if [[ \$(lsof -i:"\$1" | awk '{print \$1}' | grep "nginx") ]]; then
      #echo "nginx"
      isnginx=1
    fi
    lsof -i:"\$1" | awk '{print \$2}' | grep -v "PID" | xargs kill -9
    echo -e "\033[34mkill 完成\033[0m"
    sleep 1
  fi
}

echo -e "\033[34m续签证书\033[0m"
port_exist_check 80
port_exist_check 443
sleep 3
~/.acme.sh/acme.sh --issue -d $DOMAIN --standalone -k ec-256 --force
sleep 1
cp -r /root/.acme.sh/${DOMAIN}_ecc/*.* /etc/ssl/private
set_nobody_certificate \$ssl_cert_dir
echo -e "\033[34m证书续签完成\033[0m"
echo -e "\033[34m重启x-ui\033[0m"
x-ui restart
echo -e "\033[34m重启nginx\033[0m"
sudo systemctl restart nginx
EOF
  
  chmod +x $ssl_cert_dir/auto_ssl.sh
  echo  -e "${Blue}auto_ssl.sh运行权限完成${EndColor}"
  #命令 crontab -e
  #sed -i '$a0 1 1 * * bash '$ssl_cert_dir'/auto_ssl.sh' /var/spool/cron/crontabs/root
    isautogetssl=0
  #export res=$(echo $str1  |  grep $str2)
  while read -r line
  do
     res=$(echo $line  |  grep "auto_ssl.sh")
     #echo $res
	if [[ $res == "" ]]; then
	    isautogetssl=1
	else
	    isautogetssl=0
	    break
	fi
  done </var/spool/cron/crontabs/root
  if [[ $isautogetssl == 1 ]]; then
	sed -i '$a0 1 1 */2 * bash '$ssl_cert_dir'/auto_ssl.sh' $cronpath/root
  fi
  echo  -e "${Blue}设定SSL证书自动续期完成${EndColor}"
}

function nginx_install() {
  if ! command -v nginx >/dev/null 2>&1; then
    ${INS} nginx
    judge "Nginx 安装"
  else
    print_ok "Nginx 已存在"
    ${INS} nginx
  fi
  # 遗留问题处理
  mkdir -p /etc/nginx/conf.d >/dev/null 2>&1
}

function install_nginx() {
  #echo -e "${Red}需要先安装xray，否则可能出现不可意料的错误${EndColor}"
  #sleep 5
  if [ $isins == 0 ]
  then
  	system_check
  fi
  nginx_install
  #apt-get install nginx -y
  $INS install nginx -y
  echo -e  "${Blue}nginx已安装完成${EndColor}"
  rm -rf /www/xray_web
  if [ ! -d "/www" ]; then
  mkdir /www
  fi
  if [ ! -d "/www/xray_web" ]; then
  mkdir /www/xray_web
  fi
  web_link="https://raw.githubusercontent.com/wpyok500/myxray_onekey/main/3DCEList.zip"
  read -rp "伪装站点：1、元素周期表；2、计算器；" web_num
  case $web_num in
  1)
    web_link="https://raw.githubusercontent.com/wpyok500/myxray_onekey/main/3DCEList.zip"
    ;;
  2)
    web_link="https://raw.githubusercontent.com/wpyok500/myxray_onekey/main/jsq.zip"
    ;;
  *)
    echo -e "${Red}输入错误，将使用元素周期表伪装站点${EndColor}"
    ;;
  esac
  sed -i 's/root   \/usr\/share\/nginx\/html/root   \/www\/xray_web/g' ${nginx_conf}
  sed -i 's/index  index.html index.htm/index index.php index.html index.htm default.php default.htm default.html/g' ${nginx_conf}
  wget --no-check-certificate -c  -O /www/xray_web/web.zip $web_link
  unzip -d /www/xray_web /www/xray_web/web.zip
  rm -rf /www/xray_web/web.zip
  systemctl start nginx && systemctl restart nginx
  echo -e  "${Blue}伪装站点完成${EndColor}"
}

function get_xray_lasttags() {
  # 下载xray_releases  json文档
  wget -N --no-check-certificate -q "https://api.github.com/repos/XTLS/Xray-core/releases" -O xray_releases  && chmod  777 xray_releases
  #获取最新版本
  tmp_file=xray_releases && releases_list=($(sed 'y/,/\n/' "$tmp_file" | grep 'tag_name' | awk -F '"' '{print $4}')) && echo  xray最新版本：${releases_list[0]/v/}
  last_version=${releases_list[0]/v/}
}
get_current_version() {
  #获取xray当前版本
  # Get the CURRENT_VERSION
  if [[ -f '/usr/local/bin/xray' ]]; then
    current_version="$(/usr/local/bin/xray -version | awk 'NR==1 {print $2}')"
    run_status="$(systemctl status xray | awk 'NR==5 {print $2 $3}')" && echo ${run_status}
    #current_version="v${current_version#v}"
  else
    current_version=""
  fi 
}

get_xray_status() {
  if [[ -f '/usr/local/bin/xray' ]]; then
    current_version="$(/usr/local/bin/xray -version | awk 'NR==1 {print $2}')"
    run_status="$(systemctl status xray | awk 'NR==5 {print $2 $3}')"

    echo -e "当前Xray版本：${current_version}  运行状态：${run_status}"
    echo -e "本地脚本版本：${shell_version}"
    #current_version="v${current_version#v}"
  else
    current_version=""
  fi  
}

function createnginxconf() {
DOMAIN=$(cat ${ssl_cert_dir}/domain)
rm -rf ${nginx_conf}
cat > ${nginx_conf} <<-EOF
server
{
    listen 443 ssl http2 so_keepalive=on;
    #配置站点域名，多个以空格分开
    server_name _;
    index index.php index.html index.htm default.php default.htm default.html;
    root /www/xray_web;
    charset utf-8;
    
    #SSL-START SSL相关配置，请勿删除或修改下一行带注释的404规则
    #error_page 404/404.html;
    #HTTP_TO_HTTPS_START
    
    #SSL-START SSL相关配置，请勿删除或修改下一行带注释的404规则
    #error_page 404/404.html;
    #HTTP_TO_HTTPS_START

    ssl_certificate    /etc/ssl/private/fullchain.cer;
    ssl_certificate_key    /etc/ssl/private/$DOMAIN.key;
    ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers on; 
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    add_header Strict-Transport-Security "max-age=31536000";
    error_page 497  https://;

    client_header_timeout 52w;
    keepalive_timeout 52w;

    # 在 location 后填写 /你的 ServiceName
    location /$DOMAIN {
        if (\$content_type !~ "application/grpc") {
            return 404;
        }
        client_max_body_size 0;
        client_body_buffer_size 512k;
        grpc_set_header X-Real-IP \$remote_addr;
        client_body_timeout 52w;
        grpc_read_timeout 52w;
        #以前github仓推荐配置，注意xray配置也需修改listen
        grpc_pass grpc://127.0.0.1:2002;
        #现在github仓推荐配置，注意xray配置也需修改listen
        #grpc_pass unix:/dev/shm/Xray-VLESS-gRPC.socket;
    }
}
EOF
}

function createxrayconf() {
  rm -rf /usr/local/etc/xray/config.json
  DOMAIN=$(cat ${ssl_cert_dir}/domain)
  UUID=$(cat /proc/sys/kernel/random/uuid)
  cat > /usr/local/etc/xray/config.json <<-EOF
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      //以前github仓推荐配置，注意nginx配置也需修改grpc_pass
      "port": 2002,
      "listen": "127.0.0.1",
      //现在github仓推荐配置，注意nginx配置也需修改grpc_pass
      //"listen": "/dev/shm/Xray-VLESS-gRPC.socket,0666",
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$UUID"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "grpc",
        "grpcSettings": {
          "serviceName": "$DOMAIN"
        }
      }
    }
  ],
  "outbounds": [
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {}
    },
    {
      "tag": "blocked",
      "protocol": "blackhole",
      "settings": {}
    }
  ],
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {
        "type": "field",
        "ip": [
          "geoip:private"
        ],
        "outboundTag": "blocked"
      }
    ]
  }
}
EOF
}

function createxrayrconf() {
  xrayrprot=$1
  echo -e "${xrayrprot}"
  rm -rf /usr/local/etc/xray/config.json
  DOMAIN=$(cat ${ssl_cert_dir}/domain)
  UUID=$(cat /proc/sys/kernel/random/uuid)
  shortIds=$(openssl rand -hex 8)
  grpcrkey=$(xray x25519)
  privatekey=$(echo $grpcrkey | awk 'NR==1 {print $3}')
  publicKey=$(echo $grpcrkey | awk 'NR==1 {print $6}')
  #echo -e "${grpcrkey}"
  cat > /usr/local/etc/xray/config.json <<-EOF
{
    "log": {
        "loglevel": "warning"
    },
    "routing": {
        "domainStrategy": "IPIfNonMatch",
        "rules": [
            {
                "type": "field",
                "port": "80",
                "network": "udp",
                "outboundTag": "block"
            },
            {
                "type": "field",
                "ip": ["geoip:private"],
                "outboundTag": "block"
            }
        ]
    },
    "inbounds": [
        {
            "listen": "0.0.0.0",
            "port": $xrayrprot,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "$UUID",
                        "flow": ""
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "grpc",
                "security": "reality",
                "realitySettings": {
                    "show": false,
                    "dest": "www.yahoo.com:443",
                    "xver": 0,
                    "serverNames": ["www.yahoo.com", "news.yahoo.com"],
                    "privateKey": "$privatekey",
                    "publicKey": "$publicKey",
                    "shortIds": ["$shortIds"]
                },
                "grpcSettings": {
                    "serviceName": "$DOMAIN"
                }
            },
            "sniffing": {
                "enabled": true,
                "destOverride": ["http", "tls", "quic"]
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        },
        {
            "protocol": "blackhole",
            "tag": "block"
        }
    ],
    "policy": {
        "levels": {
            "0": {
                "handshake": 2,
                "connIdle": 120
            }
        }
    }
}
EOF
}

#链接
function xray_link() {
  UUID=$(cat ${xray_conf_dir}/config.json | sed 's|//.*||' | jq .inbounds[0].settings.clients[0].id | tr -d '"')
  DOMAIN=$(cat ${ssl_cert_dir}/domain)
  qrencode_GL
  
  print_ok "=====================Xray链接======================"
  echo -e "URL 链接（VLESS + grpc +  TLS）"
  #echo "vless://$UUID@$DOMAIN:443?encryption=none&flow=xtls-rprx-direct-udp443&security=tls&type=grpc&serviceName=$DOMAIN&mode=gun#grpc_$DOMAIN"
  echo "vless://$UUID@$DOMAIN:443?encryption=none&security=tls&type=grpc&serviceName=$DOMAIN&sni=$DOMAIN&mode=gun#grpc_$DOMAIN"
  
  #qrencode_GL "vless://$UUID@$DOMAIN:443?encryption=none&security=tls&type=grpc&serviceName=$DOMAIN&mode=gun#grpc_$DOMAIN"
  rm -rf /www/xray_web/qrencode
  mkdir /www/xray_web/qrencode
  quuid=$(cat /proc/sys/kernel/random/uuid)
  qrencode  -o "/www/xray_web/qrencode/${quuid}.png" "vless://$UUID@$DOMAIN:443?encryption=none&security=tls&type=grpc&serviceName=$DOMAIN&sni=$DOMAIN&mode=gun#grpc_$DOMAIN"

  echo -e "\n二维码链接：\nhttps://$DOMAIN/qrencode/${quuid}.png"
  print_ok "=====================Xray链接======================"
}

function xrayr_link() {
  UUID=$(cat ${xray_conf_dir}/config.json | sed 's|//.*||' | jq .inbounds[0].settings.clients[0].id | tr -d '"')
  DOMAIN=$(cat ${ssl_cert_dir}/domain)
  
  security=$(cat ${xray_conf_dir}/config.json | sed 's|//.*||' | jq .inbounds[0].streamSettings.security | tr -d '"')  &&  echo -e ${security}
  privateKey=$(cat ${xray_conf_dir}/config.json | sed 's|//.*||' | jq .inbounds[0].streamSettings.realitySettings.privateKey | tr -d '"')  &&  echo -e ${privateKey}
  publicKey=$(cat ${xray_conf_dir}/config.json | sed 's|//.*||' | jq .inbounds[0].streamSettings.realitySettings.publicKey | tr -d '"')  &&  echo -e ${publicKey}
  shortIds=$(cat /usr/local/etc/xray/config.json | sed 's|//.*||' | jq .inbounds[0].streamSettings.realitySettings.shortIds | tr -d '"[]\n ')  &&  echo -e ${shortIds}
  serviceName=$(cat ${xray_conf_dir}/config.json | sed 's|//.*||' | jq .inbounds[0].streamSettings.grpcSettings.serviceName | tr -d '"')  &&  echo -e ${serviceName}
  portr=$(cat ${xray_conf_dir}/config.json | sed 's|//.*||' | jq .inbounds[0].port | tr -d '"')  &&  echo -e ${portr}
  
  qrencode_GL
  
  print_ok "=====================Xray链接======================"
  echo -e "URL 链接（VLESS + grpc +  reality）"
  echo "vless://$UUID@$DOMAIN:$portr?encryption=none&security=reality&sni=www.yahoo.com&fp=chrome&pbk=$publicKey&sid=$shortIds&spx=%2F&type=grpc&serviceName=$DOMAIN&mode=gun#grpc-reality_$DOMAIN"
  
  #qrencode_GL "vless://$UUID@$DOMAIN:443?encryption=none&security=tls&type=grpc&serviceName=$DOMAIN&mode=gun#grpc_$DOMAIN"
  rm -rf /www/xray_web/qrencode
  mkdir /www/xray_web/qrencode
  quuid=$(cat /proc/sys/kernel/random/uuid)
  qrencode  -o "/www/xray_web/qrencode/${quuid}.png" "vless://$UUID@$DOMAIN:$portr?encryption=none&security=reality&sni=www.yahoo.com&fp=chrome&pbk=$publicKey&sid=$shortIds&spx=%2F&type=grpc&serviceName=$DOMAIN&mode=gun#grpc-reality_$DOMAIN"

  echo -e "\n二维码链接：\nhttps://$DOMAIN/qrencode/${quuid}.png"
  print_ok "=====================Xray链接======================"
}



# 安装qrencode
function qrencode_GL() {
	if [[ $(dpkg -l | grep -w qrencode) ]];
	then
	      echo ""
	else
		echo -e "\n${Red}系统未安装二维码qrencode，开始安装qrencode${EndColor}"
		check_system
		$INS install -y qrencode
	     #exit 1
	fi
}


#更新xray
function uapate_xray {
  get_xray_lasttags
  bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --version ${last_version}
}

#更换域名
function update_domain() {
  systemctl stop xray
  rm -rf /etc/ssl/private
	mkdir /etc/ssl/private && chmod 777 /etc/ssl/private
  domain_check
	echo $domain >$ssl_cert_dir/domain #记录域名
	autoGetSSL
	manual_certificate
	update_confinfo
	autoUPxray
	systemctl start xray
  systemctl restart nginx
  xray_link
}

function update_confinfo() {
#/usr/local/etc/xray/config.json
DOMAIN=$(cat ${ssl_cert_dir}/domain)
chmod 777 ${xray_conf_dir}/config.json
sed -i 's/"serviceName": ".*"$/"serviceName": "'${DOMAIN}'"/g'  ${xray_conf_dir}/config.json
chmod 755 ${xray_conf_dir}/config.json

chmod 777 ${nginx_conf}
sed -i 's/"id": ".*"$/"id": "'${DOMAIN}'"/g'  ${nginx_conf}
sed -i 's/ssl_certificate_key    \/etc\/ssl\/private\/.*$/ssl_certificate_key    \/etc\/ssl\/private\/'${DOMAIN}'.key;/g' ${nginx_conf}
sed -i 's/location \/.*$/location \/'${DOMAIN}' {/g' ${nginx_conf}
chmod 755 ${nginx_conf}
}

#每2天自动更新xray
function set_up_xray() {
if [[ -f '/usr/local/bin/xray' ]]; then
rm -rf $ssl_cert_dir/auto_up_xray.sh
cat > $ssl_cert_dir/auto_up_xray.sh <<-EOF
#!/bin/bash
last_version=""
function get_xray_lasttags() {
  # 下载xray_releases  json文档
  wget -N --no-check-certificate -q "https://api.github.com/repos/XTLS/Xray-core/releases" -O /home/wpyadmin/xray_releases  && chmod  777 /home/wpyadmin/xray_releases
  #获取最新版本
  tmp_file=/home/wpyadmin/xray_releases && releases_list=(\$(sed 'y/,/\n/' "\$tmp_file" | grep 'tag_name' | awk -F '"' '{print \$4}')) && echo  xray最新版本：\${releases_list[0]/v/}
  last_version=\${releases_list[0]/v/}
}
function uapate_xray {
  get_xray_lasttags
  bash -c "\$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --version \${last_version}
}
uapate_xray
EOF
  fi 
}

# xray reality connfig
function initXrayr() {
      echo -e "${Red}是否关闭Nginx [Y/N]?${EndColor}"
  		read -r stop_nginx
  		#read -rp "${Red}是否关闭Nginx [Y/N]?${EndColor}" stop_nginx
		  [ -z "$stop_nginx" ] && stop_nginx="N"
		  case $stop_nginx in
        [yY][eE][sS] | [yY])
		    systemctl stop nginx
		    xrayport=443
		    ;;
		  *) ;;
		  esac
		  chmod 777 $xray_conf_dir/config.json
      rm -rf $xray_conf_dir/config.json
      createxrayrconf "${xrayport}"
      #systemctl stop xray && systemctl start xray && systemctl status xray
      systemctl stop xray && systemctl start xray
      xrayr_link
}

#每2天自动更新xray
function auto_up_xray() {
  while read -r line
  do
     #echo $line
     res=$(echo $line  |  grep "auto_up_xray.sh")
     #echo $res
	if [[ $res == "" ]]; then
	    isautoupxray=1
	else
	    isautoupxray=0
	    break
	fi
  done <$cronpath/root
  if [[ $isautoupxray == 1 ]]; then
	sed -i '$a0 1 */2 * * bash '$ssl_cert_dir'/auto_up_xray.sh' $cronpath/root
  fi
  sed -i '/install-geodata/d' "/var/spool/cron/crontabs/root"
  sed -i '$a0 1 */2 * * bash -c "\$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install-geodata' $cronpath/root
}

#每2天自动更新xray
function autoUPxray() {
if [[ -f '/usr/local/bin/xray' ]]; then
auto_up_xray
set_up_xray
echo -e  "${Blue}设置完成${EndColor}"
fi 
}

function modify_uuid() {
	UUID=$(cat /proc/sys/kernel/random/uuid)
	#sed -i 's/"id": ""/"id": "'${UUID}'"/g'  $xray_conf_dir/config.json
	sed -i 's/"id": ".*"$/"id": "'${UUID}'"/g'  $xray_conf_dir/config.json
	systemctl stop xray
	systemctl start xray
	echo  -e "${Blue}UUID更改完成${EndColor}"
	xray_link
}

function install_myxui() {
	echo -e  "${Blue}开始安装${EndColor}"
	isins=1	
	is_root
	system_check
	port_exist_check 80
	port_exist_check 443
	$INS update -y && $INS install -y jq openssl cron socat curl unzip vim tar qrencode
	install_acme
	autoGetSSL
	install_nginx
	#firewall_install
	echo -e  "${Blue}安装xray${EndColor}"
	get_xray_lasttags
	bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --version ${last_version}
	echo -e  "${Blue}xray安装完成${EndColor}"
	#update_geoip
	echo -e  "${Blue}下载更新 geoip.dat and geosite.dat${EndColor}"
	bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install-geodata
	systemctl stop xray
	createnginxconf
	createxrayconf
	nginx -s reload &&  systemctl restart nginx
	#xray run /usr/local/etc/xray/config.json
	systemctl start xray
	echo -e "设置每2天自动更新xray和geoip.dat、geosite.dat"
	autoUPxray
	echo -e  "${Blue}全部安装完成${EndColor}"
	echo -e "${Purple}公钥文件路径： $ssl_cert_dir/fullchain.cer ${EndColor}"
  echo -e "${Purple}密钥文件路径： $ssl_cert_dir/$domain.key ${EndColor}"
  xray_link
  echo "请在CDN开启GRPC开关，同时也可以开启CDN代理"
}

menu() {
echo -e "\t Xray 辅助安装管理脚本 ${Red}[by 福建-兮]${Font}"
echo -e "${Green}1.  安装 xray grpc"
echo -e "${Green}2.  安装 4 合 1 BBR、锐速安装脚本${EndColor}"
echo -e "${Green}3   手动更新SSL证书${EndColor}"
echo -e "${Green}4   安装firwall防火墙${EndColor}"
echo -e "${Green}5   firwall防火墙端口管理${EndColor}"
echo -e "${Green}6   更换伪装站点${EndColor}"
echo -e "${Green}7   获取xray客户端链接${EndColor}"
echo -e "${Green}8   卸载xray${EndColor}"
echo -e "${Green}9   查看证书路径${EndColor}"
echo -e "${Green}10  更新geoip、geosite${EndColor}"
echo -e "${Green}11  更换域名"
echo -e "${Green}12  更新xray"
echo -e "${Green}13  更换UUID"
echo -e "${Green}14  设置每2天自动更新xray和geoip.dat、geosite.dat${Red}[此项默认已设置]${EndColor}"
echo -e "${Green}15  使用GRPC over Reality配置"
echo -e "${Green}16  获取xray Reality客户端链接${EndColor}"
echo -e "${Green}0   更新脚本${EndColor}"
get_xray_status
read -rp "请输入数字：" menu_num
  case $menu_num in
  1)
    install_myxui
    ;;
  2)
    bbrjiashu
    ;;
  3)
    #domain_check
    #generate_certificate
    #autoGetSSL
    manual_certificate
    systemctl restart nginx
    ;; 
  4)
    firewall_install
    ;;
  5)
    firewall_GL
    ;;
  6)
    change_web
    ;;
  7)
    #createconf
    xray_link
    ;;
  8)
    remove_xui
    ;;
  9)
    DOMAIN=$(cat ${ssl_cert_dir}/domain)
    echo -e "${Purple}公钥文件路径： $ssl_cert_dir/fullchain.cer ${EndColor}"
    echo -e "${Purple}密钥文件路径： $ssl_cert_dir/$DOMAIN.key ${EndColor}"
    ;;
  10)
    update_geoip
    ;;
  11)
    update_domain
    ;;
  12)
    uapate_xray
    ;;
  13)
    modify_uuid
    ;;  
  14)
    autoUPxray
    ;; 
  15)
    initXrayr
    ;;
  16)
    #createconf
    xrayr_link
    ;;     
  0)
    update_sh
    ;;   
  *)
    echo -e "${Red}请输入正确的数字${EndColor}"
    ;;
  esac
}
menu "$@"
