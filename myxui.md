# x-ui 配置文件路径
1、xray配置文件：/usr/local/x-ui/bin/config.json

2、x-ui数据库（配置文件）：/etc/x-ui/x-ui.db

3、x-ui快捷启动 x-ui.service :/etc/systemd/system/  或  /usr/local/x-ui/x-ui.service

4、x-ui管理文件x-ui.sh ：/usr/local/x-ui/x-ui.sh

5、域名证书文件位置：/etc/ssl/private/fullchain.cer  和 /etc/ssl/private/你的域名.key

# 如果使用cf 记得SSL 切换成安全
![image](https://user-images.githubusercontent.com/14154547/177893982-a3ef1fb6-1356-47ba-abf4-ca08fb8a3ecd.png)


# 本文教程均按脚本默认配置配图
# 根据安装脚本时你设定的相关信息，设置X-UI面板，保存配置，并重启面板
如果你用的是反代配置和仅面板配置，重启面板即可用https://你的域名/你的面板根路径，如https://exemple.com/myxui 进行访问进入面板了
如果你用的是回落fallback配置，面板设置后请勿重启，请移步回落fallback配置教程中设置入站站点后再重启，使用https的访问方式进入面板

![image](https://user-images.githubusercontent.com/14154547/131056046-21bf142f-368c-44ca-933e-a10165237d9d.png)
# 反代配置，xray配置如下，同样根据安装脚本时你设定的相关信息进行设定,支持套用CDN
1、服务端
![image](https://user-images.githubusercontent.com/14154547/131056502-63b688ca-838f-46f7-99a6-b33da7f99554.png)
2、客户端
![image](https://user-images.githubusercontent.com/14154547/131056622-1263549f-be46-4d5c-887e-f1135f391fb0.png)
# 回落fallback配置，xray配置如下，同样根据安装脚本时你设定的相关信息进行设定
# 因X-UI目前并未完整支持fallback故无法套用CDN代理，即使完全支持，xray目前也仅vmless+ws配置支持套用CDN代理
1、服务端,这样配置后即可使用https进行访问了
回落fallback配置{"alpn":"h2","dest":"8080","xver":1}
![image](https://user-images.githubusercontent.com/14154547/131057453-a6d5df5e-dd71-41d5-8888-9e26871c618e.png)

2、客户端
使用https://你的域名/myxui/xui/inbounds访问，扫描二维码或复制连接到客户端即可

