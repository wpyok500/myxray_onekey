# myxray_onekey
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


开启ivp6:
sed -i '$anet.ipv6.conf.all.disable_ipv6=1' /etc/sysctl.conf && sed -i '$anet.ipv6.conf.default.disable_ipv6=1' /etc/sysctl.conf && sed -i '$anet.ipv6.conf.lo.disable_ipv6=1' /etc/sysctl.conf && sysctl -p && ip a
关闭ivp6:
sed -i '/net.ipv6.conf.all.disable_ipv6=1/d' /etc/sysctl.conf && sed -i '/net.ipv6.conf.default.disable_ipv6=1/d' /etc/sysctl.conf && sed -i '/net.ipv6.conf.lo.disable_ipv6=1/d' /etc/sysctl.conf && sysctl -p && ip a
