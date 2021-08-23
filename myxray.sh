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
EndColor="\033[0m"
xray_conf_dir="/usr/local/etc/xray"
cronpath="/var/spool/cron/crontabs"
isins=0 #是否检查系统
isnginx=0 #是否重启nginx


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

function autoGetSSL() {
  DOMAIN=$(cat ${xray_conf_dir}/domain)
  rm -rf $ssl_cert_dir/autogetssl.sh
  echo "#!/bin/bash" > $ssl_cert_dir/autogetssl.sh
  sed -i '$a\\n' $ssl_cert_dir/autogetssl.sh
  sed -i '$afunction port_exist_check() {\n  if [[ 0 -eq $(lsof -i:"$1" | grep -i -c "listen") ]]; then\n    echo -e "\\033[34m$1 端口未被占用\\033[0m"\n    sleep 1\n  else\n    echo -e "\\033[31m检测到 $1 端口被占用，以下为 $1 端口占用信息\\033[0m"\n    lsof -i:"$1"\n    echo -e "\\033[31m5s 后将尝试自动 kill 占用进程\\033[0m"\n    sleep 5\n    lsof -i:"$1" | awk '"'{print \$2}'"' | grep -v "PID" | xargs kill -9\n    echo -e "\\033[34mkill 完成\\033[0m"\n    sleep 1\n  fi\n}' $ssl_cert_dir/autogetssl.sh
  sed -i '$a\\n' $ssl_cert_dir/autogetssl.sh
  sed -i '$aecho -e "\\033[34m续签证书\\033[0m"' $ssl_cert_dir/autogetssl.sh
  sed -i '$aport_exist_check 80' $ssl_cert_dir/autogetssl.sh
  sed -i '$aport_exist_check 443' $ssl_cert_dir/autogetssl.sh
  sed -i '$a~/.acme.sh/acme.sh --issue -d '$DOMAIN' --standalone -k ec-256 --force'  $ssl_cert_dir/autogetssl.sh
  sed -i '$acp -r /root/.acme.sh/'$DOMAIN'_ecc/*.* '$ssl_cert_dir'' $ssl_cert_dir/autogetssl.sh
  sed -i '$acp -r /root/.acme.sh/'$DOMAIN'_ecc/*.* /usr/local/etc/xray' $ssl_cert_dir/autogetssl.sh
  sed -i '$afor file in '$xray_conf_dir'/*\ndo\n	if [ -f "$file" ]\n	then\n	  #echo "$file is file"\n		if [[ $file == *".cer"* || $file == *".pem"* || $file == *".crt"* ]]\n		then\n		    #echo "$file包含"\n		    sudo chown nobody.'$cert_group' $file\n		fi\n	fi\ndone' $ssl_cert_dir/autogetssl.sh
  sed -i '$aecho -e "\\033[34m证书续签完成\\033[0m"' $ssl_cert_dir/autogetssl.sh
  sed -i '$aecho -e "\\033[34m重启xray\\033[0m"' $ssl_cert_dir/autogetssl.sh
  sed -i '$asudo systemctl restart xray' $ssl_cert_dir/autogetssl.sh
  sed -i '$aecho -e "\\033[34m重启nginx\\033[0m"' $ssl_cert_dir/autogetssl.sh
  sed -i '$asudo systemctl restart nginx' $ssl_cert_dir/autogetssl.sh
  
  chmod +x $ssl_cert_dir/autogetssl.sh
  
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

function modify_uuid() {
	UUID=$(cat /proc/sys/kernel/random/uuid)
	sed -i 's/"id": ""/"id": "'${UUID}'"/g'  $xray_conf_dir/config.json
	echo  -e "${Blue}UUID更改完成${EndColor}"
	xray_link
}

#链接
function xray_link() {
  UUID=$(cat ${xray_conf_dir}/config.json | sed 's|//.*||' | jq .inbounds[0].settings.clients[0].id | tr -d '"')
  PORT=$(cat ${xray_conf_dir}/config.json | sed 's|//.*||' | jq .inbounds[0].port)
  FLOW=$(cat ${xray_conf_dir}/config.json | sed 's|//.*||' | jq .inbounds[0].settings.clients[0].flow | tr -d '"')
  XRAYPATH=$(cat ${xray_conf_dir}/config.json | sed 's|//.*||' | jq .inbounds[0].settings.fallbacks[1].path | tr -d '"')
  DOMAIN=$(cat ${xray_conf_dir}/domain)
  TJPWD=$(cat ${xray_conf_dir}/config.json | sed 's|//.*||' | jq .inbounds[1].settings.clients[0].password | tr -d '"')
  VMWS=$(echo "{\"v\": \"2\",\"ps\": \"VM_WS-$DOMAIN\",\"add\": \"$DOMAIN\",\"port\": \"$PORT\",\"id\": \"$UUID\",\"aid\": \"0\",\"scy\": \"auto\",\"net\": \"ws\",\"type\": \"none\",\"host\": \"$DOMAIN\",\"path\": \"/vmessws\",\"tls\": \"tls\",\"sni\": \"$DOMAIN\"}" | base64)
  VMWS=$(echo $VMWS | sed 's/\n/ /g')
  VMTCP=$(echo "{\"v\": \"2\",\"ps\": \"VM_TCP-$DOMAIN\",\"add\": \"$DOMAIN\",\"port\": \"$PORT\",\"id\": \"$UUID\",\"aid\": \"0\",\"scy\": \"auto\",\"net\": \"tcp\",\"type\": \"http\",\"host\": \"$DOMAIN\",\"path\": \"/vmesstcp\",\"tls\": \"tls\",\"sni\": \"$DOMAIN\"}" | base64)
  VMTCP=$(echo $VMTCP | sed 's/\n/ /g')

  print_ok "=====================Xray链接======================"
  echo "URL 链接（VLESS + WS +  TLS）"
  echo "vless://$UUID@$DOMAIN:$PORT?security=tls&flow=$FLOW&type=ws&path=$XRAYPATH#VL_WS_TLS-$DOMAIN"
  echo "URL 链接（VLESS + TCP +  XTLS）"
  echo "vless://$UUID@$DOMAIN:$PORT?security=xtls&flow=$FLOW#VL_XTLS-$DOMAIN"
  echo "URL 链接（VLESS + TCP +  TLS）"
  echo "vless://$UUID@$DOMAIN:$PORT?security=tls&flow=$FLOW#VL_TLS-$DOMAIN"
  echo "URL 链接（trojan）"
  echo "trojan://$TJPWD@$DOMAIN:$PORT?#TJ-$DOMAIN"
  echo "URL 链接（VMESS + WS）"
  echo "vmess://$VMWS"
  echo "URL 链接（VMESS + TCP）"
  echo "vmess://$VMTCP"
  print_ok "=====================Xray链接======================"
}

function firewall_install() {
	if [ $isins == 0 ] 
	then
  	  system_check
     fi
	$INS install -y firewalld
	firewall-cmd --zone=public --add-port=80/tcp --permanent && firewall-cmd --zone=public --add-port=443/tcp --permanent && firewall-cmd --zone=public --add-port=54321/tcp --permanent && firewall-cmd --reload
	echo -e "${Blue}安装防火墙并开启80、443端口${EndColor}"
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

function manual_certificate() {
	DOMAIN=$(cat ${xray_conf_dir}/domain)
	~/.acme.sh/acme.sh --issue -d ${DOMAIN} --standalone -k ec-256 --force
	echo -e  "${Blue}SSL证书获取完成${EndColor}"
	#~/.acme.sh/acme.sh --install-cert -d ${domain} --fullchain-file $ssl_cert_dir/fullchain.cer --key-file $ssl_cert_dir/private.key --ecc
	cp -r /root/.acme.sh/${domain}_ecc/*.* $ssl_cert_dir
	echo -e  "${Blue}SSL 证书配置到 $ssl_cert_dir${EndColor}"
	#~/.acme.sh/acme.sh --install-cert -d ${domain} --cert-file /usr/local/etc/xray/${domain}.cer --key-file /usr/local/etc/xray/${domain}.key --ecc
	cp -r /root/.acme.sh/${domain}_ecc/*.* /usr/local/etc/xray
	echo -e  "${Blue}SSL 证书配置到 /usr/local/etc/xray${EndColor}"
	systemctl restart xray
	sleep 3
	systemctl status xray
}

function generate_certificate() {
  # Xray 默认以 nobody 用户运行，证书权限适配
  #chown -R nobody.$cert_group /ssl/*
  signedcert=$(xray tls cert -domain="$local_ip" -name="$local_ip" -org="$local_ip" -expire=87600h)
  echo  -e "${Blue}生成自签名证书${EndColor}"
  #echo $signedcert
  echo $signedcert | jq '.certificate[]' | sed 's/\"//g' | tee $xray_conf_dir/self_signed_cert.pem
  echo $signedcert | jq '.key[]' | sed 's/\"//g' >$xray_conf_dir/self_signed_key.pem
  openssl x509 -in $xray_conf_dir/self_signed_cert.pem -noout || 'echo "${Red}生成自签名证书失败${EndColor}" && exit 1'
  echo -e "${Blue}生成自签名证书成功${EndColor}"
  #chown nobody.$cert_group $xray_conf_dir/self_signed_cert.pem
  #chown nobody.$cert_group $xray_conf_dir/self_signed_key.pem
  set_nobody_certificate
}

function set_nobody_certificate() {
	for file in $xray_conf_dir/*
	do
		if [ -d "$file" ]
		then 
		  #echo "$file is directory"
		  echo ""
		elif [ -f "$file" ]
		then
		  #echo "$file is file"
			if [[ $file == *".cer"* || $file == *".pem"* || $file == *".crt"* ]]
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

function update_xray() {
	bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" - install
	systemctl restart xray
	sleep 3
	systemctl status xray
}

function remove_xray() {
  bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove
  #rm -rf /usr/local/etc/xray/*.*
  rm -rf /usr/local/etc/xray
  echo -e  "${Blue}xray卸载完成${EndColor}"
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
    rm -rf /etc/ssl/private/autogetssl.sh
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

function setLinuxDateZone(){
    tempCurrentDateZone=$(date +'%z')
    echo
    if [[ ${tempCurrentDateZone} == "+0800" ]]; then
        yellow "当前时区已经为北京时间  $tempCurrentDateZone | $(date -R) "
    else 
        green " =================================================="
        yellow " 当前时区为: $tempCurrentDateZone | $(date -R) "
        yellow " 是否设置时区为北京时间 +0800区, 以便cron定时重启脚本按照北京时间运行."
        green " =================================================="
        # read 默认值 https://stackoverflow.com/questions/2642585/read-a-variable-in-bash-with-a-default-value
        read -p "是否设置为北京时间 +0800 时区? 请输入[Y/n]:" osTimezoneInput
        osTimezoneInput=${osTimezoneInput:-Y}

        if [[ $osTimezoneInput == [Yy] ]]; then
            if [[ -f /etc/localtime ]] && [[ -f /usr/share/zoneinfo/Asia/Shanghai ]];  then
                mv /etc/localtime /etc/localtime.bak
                #cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
                #rm /etc/localtime && ln -s /usr/share/zoneinfo/Universal /etc/localtime && timedatectl # UTC
			 rm /etc/localtime && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && timedatectl	
                yellow "设置成功! 当前时区已设置为 $(date -R)"
                green " =================================================="
            fi
        fi

    fi
    echo
}

function install_xray() {
	echo -e  "${Blue}开始安装${EndColor}"
	isins=1	
	is_root
	system_check
	port_exist_check 80
	port_exist_check 443
	$INS update -y && $INS install -y jq openssl cron socat curl unzip vim tar
	echo -e  "${Blue}依赖库安装完成${EndColor}"
	bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
	echo -e  "${Blue}Xray安装完成${EndColor}"
	curl https://get.acme.sh | sh && ~/.acme.sh/acme.sh --upgrade --auto-upgrade
	echo -e  "${Blue}SSL证书生成依赖库安装完成${EndColor}"
	domain_check
	echo $domain >$xray_conf_dir/domain #记录域名
	#cat > $xray_conf_dir/domain <<-EOF
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
	#~/.acme.sh/acme.sh --install-cert -d ${domain} --cert-file /usr/local/etc/xray/${domain}.cer --key-file /usr/local/etc/xray/${domain}.key --ecc
	cp -r /root/.acme.sh/${domain}_ecc/*.* /usr/local/etc/xray
	echo -e  "${Blue}SSL 证书配置到 /usr/local/etc/xray${EndColor}"
	generate_certificate
	autoGetSSL
	install_nginx
}

function vtxwjson_install() {
	install_xray
	#mv /etc/localtime /etc/localtime.bak
	#rm /etc/localtime
	#ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && timedatectl # 设置时区并同步时间 
	chmod 777 /usr/local/etc/xray && rm -rf /usr/local/etc/xray/config.json && wget --no-check-certificate -c 	"https://raw.githubusercontent.com/XTLS/Xray-examples/main/VLESS-TCP-XTLS-WHATEVER/config_server.json" -O /usr/local/etc/xray/config.json
	echo  -e "${Blue}xray配置脚本下载完成${EndColor}"
	[ -z "$UUID" ] && UUID=$(cat /proc/sys/kernel/random/uuid)
	read -rp "请输入Trojan密码(默认：12345678)：" PWD
	  [ -z "$PWD" ] && PWD="12345678"
	sed -i 's/"id": ""/"id": "'${UUID}'"/g'  /usr/local/etc/xray/config.json && sed -i 's/"\/path\/to\/fullchain.crt"/"\/usr\/local\/etc\/xray\/'${domain}'.cer"/g'  /usr/local/etc/xray/config.json && sed -i 's/"\/path\/to\/private.key"/"\/usr\/local\/etc\/xray\/'${domain}'.key"/g'  /usr/local/etc/xray/config.json && sed -i 's/"password": ""/"password": "'$PWD'"/g'  /usr/local/etc/xray/config.json
	systemctl restart xray
	if [ $isnginx == 1 ]
	then
	  systemctl restart nginx
	fi
	isfirewalld
	sleep 5
	#systemctl status xray
	xray_link
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
echo -e "\t Xray 安装管理脚本 ${Red}[by 福建-兮]${Font}"
echo -e "${Green}1.  安装 Xray (VLESS over TCP with XTLS + 回落 & 分流 to WHATEVER（终极配置）)${EndColor}"
echo -e "${Green}2.  变更 UUID${EndColor}"
echo -e "${Green}3.  安装 4 合 1 BBR、锐速安装脚本${EndColor}"
echo -e "${Green}4   卸载 Xray${EndColor}"
echo -e "${Green}5   更新 Xray-core${EndColor}"
echo -e "${Green}6   查看 Xray运行状态${EndColor}"
echo -e "${Green}7   重启 Xray并查看运行状态${EndColor}"
#echo -e "${Green}8   自签名证书${EndColor}"
echo -e "${Green}8   手动更新SSL证书${EndColor}"
echo -e "${Green}9   安装firwall防火墙${EndColor}"
echo -e "${Green}10  查看链接${EndColor}"
echo -e "${Green}11  设置自动续签证书${EndColor}"
echo -e "${Green}12  安装nginx并伪装站点${EndColor}"
echo -e "${Green}13  更换伪装站点${EndColor}"
read -rp "请输入数字：" menu_num
  case $menu_num in
  1)
    vtxwjson_install
    ;;
  2)
    modify_uuid
    ;;
  3)
    bbrjiashu
    ;;
  4)
    remove_xray
    ;;
  5)
    update_xray
    ;;
  6)
    systemctl status xray
    ;;
  7)
    systemctl restart xray
	sleep 3
	systemctl status xray
    ;;
  8)
    #domain_check
    #generate_certificate
    manual_certificate
    ;; 
  9)
    firewall_install
    ;;
  10)
    xray_link
    ;;
  11)
    autoGetSSL
    ;;
  12)
    install_nginx
    ;;
  13)
    change_web
    ;;  
  *)
    echo -e "${Red}请输入正确的数字${EndColor}"
    ;;
  esac
}
menu "$@"
