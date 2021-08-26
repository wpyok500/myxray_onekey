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
shell_version="1.0.2"

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
  sed -i 's/root   \/usr\/share\/nginx\/html/root   \/www\/xray_web/g' /etc/nginx/conf.d/default.conf
  sed -i 's/index  index.html index.htm/index index.php index.html index.htm default.php default.htm default.html/g' /etc/nginx/conf.d/default.conf
  wget --no-check-certificate -c  -O /www/xray_web/web.zip $web_link
  unzip -d /www/xray_web /www/xray_web/web.zip
  rm -rf /www/xray_web/web.zip
  systemctl start nginx && systemctl restart nginx
  echo -e  "${Blue}伪装站点完成${EndColor}"
}

function createnginxconf() {
  rm -rf /etc/nginx/conf.d/default.conf
  DOMAIN=$(cat ${ssl_cert_dir}/domain)
  cat > /etc/nginx/conf.d/default.conf <<-EOF
server
{
    ##需要更改的地方：x-ui面板设定(52、53行)、Xray反代vless协议设定(59、61行)
    listen 80 default_server;
    listen [::]:80 default_server;
    listen 443 ssl http2;
    listen [::]:443 ssl;
    #配置站点域名，多个以空格分开
    server_name _;
    index index.php index.html index.htm default.php default.htm default.html;
    root /www/xray_web;

    #SSL-START SSL相关配置，请勿删除或修改下一行带注释的404规则
    #error_page 404/404.html;
    #HTTP_TO_HTTPS_START

    ssl_certificate    /etc/ssl/private/fullchain.cer;
    ssl_certificate_key    /etc/ssl/private/$DOMAIN.key;
    #ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
    ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
    ssl_prefer_server_ciphers on; 
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    add_header Strict-Transport-Security "max-age=31536000";
    error_page 497  https://;

    
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
    location /$vlpath {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:$vlPORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
        proxy_read_timeout 300s;
        # Show realip in v2ray access.log
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  }

}
EOF
}

function fallbackconf() 
{
	read -rp "请输入回落fallback端口号(默认：54991)：" fallbackPORT
      [ -z "$fallbackPORT" ] && fallbackPORT="54991"
      if [[ $fallbackPORT -le 0 ]] || [[ $fallbackPORT -gt 65535 ]]; then
        echo "请输入 0-65535 之间的值"
        exit 1
      fi
	rm -rf /etc/nginx/conf.d/default.conf
	cat > /etc/nginx/conf.d/default.conf <<-EOF
server
{
    ##需要更改的地方：x-ui面板设定(35、36行)
    listen 80 default_server;
    listen [::]:80 default_server;

    listen $fallbackPORT http2 proxy_protocol;
    
    #配置站点域名，多个以空格分开
    server_name _;
    index index.php index.html index.htm default.php default.htm default.html;
    root /www/xray_web;

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

function xuiconf() {
  echo -e "${Blue}nginx相关x-ui设置，请注意确保与x-ui的面板设置保持一致${EndColor}"
  #sleep 3
  read -rp "请输入x-ui面板根路径(默认：myxui)：" rootpath
  [ -z "$rootpath" ] && rootpath="myxui"
  read -rp "请输入面板端口号(默认：54321)：" xuiPORT
      [ -z "$xuiPORT" ] && xuiPORT="54321"
      if [[ $xuiPORT -le 0 ]] || [[ $xuiPORT -gt 65535 ]]; then
        echo "请输入 0-65535 之间的值"
        exit 1
      fi
}

function vlessconf() {
  echo -e "${Blue}nginx相关x-ui设置，请注意确保与x-ui的VELSS设置保持一致${EndColor}"
  #sleep 3
  read -rp "请输入反代路径(默认：datevl)：" vlpath
  [ -z "$vlpath" ] && vlpath="datevl"
  read -rp "请输入面板端口号(默认：54992)：" vlPORT
      [ -z "$vlPORT" ] && vlPORT="54992"
      if [[ $vlPORT -le 0 ]] || [[ $vlPORT -gt 65535 ]]; then
        echo "请输入 0-65535 之间的值"
        exit 1
      fi
}

function createconf() {
	xuiconf
	vlessconf
	createnginxconf
	systemctl restart nginx
	echo -e "${Blue}nginx 配置完成${EndColor}"
}

function createfallbackconf() {
	xuiconf
	fallbackconf
	systemctl restart nginx
	echo -e "${Red}使用回落配置，请到x-ui面板配置fallback相关设置，否则伪装站点无法正常使用https访问${EndColor}"
	echo -e "fallback配置{"alpn": "h2","dest": $fallbackPORT,"xver": 1}"
	echo -e "${Blue}nginx 配置完成${EndColor}"
	#sleep 2
}

menu_nginx() {
echo -e "\t x-ui nginx配置 ${Red}[by 福建-兮]${Font}"
echo -e "${Green}1.  反代配置"
echo -e "${Green}2.  回落fallback配置"
read -rp "请输入数字：" menu_nginx_conf
[ -z "$menu_nginx_conf" ] && menu_nginx_conf="54992"
  case $menu_nginx_conf in
  1)
    createconf
    ;;
  2)
    createfallbackconf
    ;;
  *)
    echo -e "${Red}输入错误，使用反代配置${EndColor}"
    createconf
    ;;
  esac
}

function autoGetSSL() {
  DOMAIN=$(cat ${ssl_cert_dir}/domain)
  rm -rf $ssl_cert_dir/autogetssl.sh
  
  cat > $ssl_cert_dir/autogetssl.sh <<-EOF
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
  
  chmod +x $ssl_cert_dir/autogetssl.sh
  echo  -e "${Blue}autogetssl.sh运行权限完成${EndColor}"
  #sed -i '$a0 1 1 * * bash '$ssl_cert_dir'/autogetssl.sh' /var/spool/cron/crontabs/root
  isautogetssl=0
  #export res=$(echo $str1  |  grep $str2)
  while read line
  do
     res=$(echo $line  |  grep "autogetssl")
     #echo $res
	if [[ $res == "" ]]; then
	    isautogetssl=1
	else
	    isautogetssl=0
	    break
	fi
  done </var/spool/cron/crontabs/root
  
  if [[ $isautogetssl == 1 ]]; then
	    sed -i '$a0 1 1 */2 * bash '$ssl_cert_dir'/autogetssl.sh' $cronpath/root
  fi
  echo  -e "${Blue}设定SSL证书自动续期完成${EndColor}"
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
			firewall-cmd --zone=public --add-port=80/tcp --permanent && firewall-cmd --zone=public --add-port=443/tcp --permanent && firewall-cmd --zone=public --add-port=54321/tcp --permanent && firewall-cmd --reload
			systemctl restart firewalld.service #systemctl start firewalld.service
			firewall-cmd --list-all
			echo -e "${Blue}安装防火墙并开启80、443、54321端口${EndColor}"
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
  ol_version=$(curl -L -s https://raw.githubusercontent.com/wpyok500/myxray_onekey/main/myxui.sh | grep "shell_version=" | head -1 | awk -F '=|"' '{print $3}')
  if [[ "$shell_version" != "$(echo -e "$shell_version\n$ol_version" | sort -rV | head -1)" ]]; then
    print_ok "存在新版本，是否更新 [Y/N]?"
    read -r update_confirm
    case $update_confirm in
    [yY][eE][sS] | [yY])
      wget -N --no-check-certificate -q "https://raw.githubusercontent.com/wpyok500/myxray_onekey/main/myxui.sh" && chmod +x myxui.sh
      echo -e "${Blue}更新完成${EndColor}"
      echo -e "您可以通过 bash $0 执行本程序"
      exit 0
      ;;
    *) ;;
    esac
  else
    echo -e "${Blue}当前版本为最新版本${EndColor}"
    echo -e "您可以通过 bash $0 执行本程序"
  fi
}

function manual_certificate() {
	DOMAIN=$(cat ${ssl_cert_dir}/domain)
	port_exist_check 80
	~/.acme.sh/acme.sh --issue -d ${DOMAIN} --standalone -k ec-256 --force
	echo -e  "${Blue}SSL证书获取完成${EndColor}"
	#~/.acme.sh/acme.sh --install-cert -d ${domain} --fullchain-file $ssl_cert_dir/fullchain.cer --key-file $ssl_cert_dir/private.key --ecc
	cp -r /root/.acme.sh/${domain}_ecc/*.* $ssl_cert_dir
	echo -e  "${Blue}SSL 证书配置到 $ssl_cert_dir${EndColor}"
	x-ui restart
	sleep 3
	x-ui status
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

function bbrjiashu(){
	wget -N --no-check-certificate "https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
}

function remove_xui() {
	x-ui uninstall
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
    #sed -i '/autogetssl/d' /var/spool/cron/crontabs/root
    rm -rf $ssl_cert_dir/autogetssl.sh
    sed -i '/autogetssl/d' $cronpath/root
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



function install_myxui() {
	echo -e  "${Blue}开始安装${EndColor}"
	isins=1	
	is_root
	system_check
	port_exist_check 80
	port_exist_check 443
	port_exist_check 54321
	$INS update -y && $INS install -y jq openssl cron socat curl unzip vim tar
	echo -e  "${Blue}依赖库安装完成${EndColor}"
	curl https://get.acme.sh | sh && ~/.acme.sh/acme.sh --upgrade --auto-upgrade
	echo -e  "${Blue}SSL证书生成依赖库安装完成${EndColor}"
	domain_check
	echo $domain >$ssl_cert_dir/domain #记录域名
	#cat > $ssl_cert_dir/domain <<-EOF
	#$domain
	#EOF
	#firewall_install
	echo -e  "${Blue}安装x-ui${EndColor}"
	bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
	echo -e  "${Blue}x-ui安装完成${EndColor}"
	~/.acme.sh/acme.sh --set-default-ca --server zerossl #Letsencrypt.ort BuyPass.com
	read -rp "请输入你的邮箱信息(eg: mymail@gmail.com):" mymail
	~/.acme.sh/acme.sh --register-account -m ${mymail}
	~/.acme.sh/acme.sh --issue -d ${domain} --standalone -k ec-256 --force #webroot
	echo -e  "${Blue}SSL证书获取完成${EndColor}"
	#~/.acme.sh/acme.sh --install-cert -d ${domain} --fullchain-file $ssl_cert_dir/fullchain.cer --key-file $ssl_cert_dir/private.key --ecc
	cp -r /root/.acme.sh/${domain}_ecc/*.* $ssl_cert_dir
	echo -e  "${Blue}SSL 证书配置到 $ssl_cert_dir${EndColor}"
	set_nobody_certificate $ssl_cert_dir
	autoGetSSL
	install_nginx
	#createconf
	menu_nginx
	echo -e  "${Purple}请自行记录证书路径，后续x-ui面板可能需要设置${EndColor}"
	echo -e "${Purple}公钥文件路径： $ssl_cert_dir/fullchain.cer ${EndColor}"
     echo -e "${Purple}密钥文件路径： $ssl_cert_dir/$domain.key ${EndColor}"
	echo "如果是全新安装x-ui，请使用http://${local_ip}:54321访问并进行xui面板设置，用户名和密码默认都是 admin"
	echo "请自行确保此端口没有被其他程序占用，并且确保 54321 端口已放行"
}

function domain_check() {
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

function is_root() {
  if [[ 0 == "$UID" ]]; then
    echo -e  "${Blue}当前用户是 root 用户，开始安装流程${EndColor}"
  else
    echo -e  "${Red}当前用户不是 root 用户，请切换到 root 用户后重新执行脚本${EndColor}"
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
    $INS install -y lsb-release gnupg2

    echo "deb http://nginx.org/packages/debian $(lsb_release -cs) nginx" >/etc/apt/sources.list.d/nginx.list
    curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -

    apt update
  elif [[ "${ID}" == "ubuntu" && $(echo "${VERSION_ID}" | cut -d '.' -f1) -ge 16 ]]; then
    echo -e  "${Blue}当前系统为 Ubuntu ${VERSION_ID} ${UBUNTU_CODENAME}${EndColor}"
    INS="apt-get"
    # 清除可能的遗留问题
    rm -f /etc/apt/sources.list.d/nginx.list
    $INS install -y lsb-release gnupg2

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

  $INS  install -y dbus

  # 关闭各类防火墙
  systemctl stop firewalld
  systemctl disable firewalld
  systemctl stop nftables
  systemctl disable nftables
  systemctl stop ufw
  systemctl disable ufw
}

menu() {
echo -e "\t x-ui 辅助安装管理脚本 ${Red}[by 福建-兮]${Font}"
echo -e "${Green}1.  安装 x-ui"
echo -e "${Green}2.  安装 4 合 1 BBR、锐速安装脚本${EndColor}"
echo -e "${Green}3   手动更新SSL证书${EndColor}"
echo -e "${Green}4   安装firwall防火墙${EndColor}"
echo -e "${Green}5   firwall防火墙端口管理${EndColor}"
echo -e "${Green}6   更换伪装站点${EndColor}"
echo -e "${Green}7   nginx配置xui相关设置${EndColor}"
echo -e "${Green}8   卸载x-ui${EndColor}"
echo -e "${Green}9   查看证书路径${EndColor}"
echo -e "${Green}0   更新脚本${EndColor}"
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
    menu_nginx
    ;;
  8)
    remove_xui
    ;;
  9)
    DOMAIN=$(cat ${ssl_cert_dir}/domain)
    echo -e "${Purple}公钥文件路径： $ssl_cert_dir/fullchain.cer ${EndColor}"
    echo -e "${Purple}密钥文件路径： $ssl_cert_dir/$DOMAIN.key ${EndColor}"
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
