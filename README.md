使用脚本安装过程前，如有套CF CDN代理请先关闭，证书安装时要验证ip

# myxray_onekey (有问题，没时间处理)
xray VLESS over TCP with XTLS + 回落 &amp; 分流 to WHATEVER（终极配置）一键安装脚本

安装脚本
```
wget -N --no-check-certificate -q "https://raw.githubusercontent.com/wpyok500/myxray_onekey/main/myxray.sh" && chmod +x myxray.sh && bash myxray.sh
```
重新启动脚本，可用如下命令直接调用
```
bash myxray.sh
```
本脚本使用官方配置库中的
https://github.com/XTLS/Xray-examples/tree/main/VLESS-TCP-XTLS-WHATEVER

# x-ui 一键辅助安装脚本（nginx openssl acme 伪装站点 自动续签证书）
安装脚本
```
wget -N --no-check-certificate -q "https://raw.githubusercontent.com/wpyok500/myxray_onekey/main/myxui.sh" && chmod +x myxui.sh && bash myxui.sh
```
重新启动脚本，可用如下命令直接调用
```
bash myxui.sh
```

> [# myxui脚本教程](https://github.com/wpyok500/myxray_onekey/blob/main/myxui.md)

# xray grpc 一键安装脚本
```
wget -N --no-check-certificate -q "https://raw.githubusercontent.com/wpyok500/myxray_onekey/main/xray_grpc.sh" && chmod +x xray_grpc.sh && bash xray_grpc.sh
```

！！！grpc脚本请注意在cf cdn 处开启grpc服务。


脚本主要参考自https://github.com/wulabing/Xray_onekey，特此感谢大佬。

···
installXrayService() {
    echoContent skyBlue "\n进度  $1/${totalProgress} : 配置Xray开机自启"
    if [[ -n $(find /bin /usr/bin -name "systemctl") ]]; then
        rm -rf /etc/systemd/system/xray.service
        touch /etc/systemd/system/xray.service
        execStart='/etc/v2ray-agent/xray/xray run -confdir /etc/v2ray-agent/xray/conf'
        cat <<EOF >/etc/systemd/system/xray.service
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target
[Service]
User=root
ExecStart=${execStart}
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000
[Install]
WantedBy=multi-user.target
EOF
        systemctl daemon-reload
        systemctl enable xray.service
        echo -e " ---> 配置Xray开机自启成功"
    fi
}
···
