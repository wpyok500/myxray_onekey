x-ui fallback 配置 443 -> trojan -> 80 实现伪装站点，本配置未回落到其他协议 ，请参照官方配置自行回落到vmless+ws(+cdn)
~~~
{
  "log": null,
  "routing": {
    "rules": [
      {
        "inboundTag": [
          "api"
        ],
        "outboundTag": "api",
        "type": "field"
      },
      {
        "ip": [
          "geoip:private"
        ],
        "outboundTag": "blocked",
        "type": "field"
      },
      {
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ],
        "type": "field"
      }
    ]
  },
  "dns": null,
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 62789,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "streamSettings": null,
      "tag": "api",
      "sniffing": null
    },
    {
      "listen": null,
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "f163141e-2fr6-4705-9c1f-d945c1b9fc31",
            "flow": "xtls-rprx-direct"
          }
        ],
        "decryption": "none",
        "fallbacks": [
          {
            "name": "",
            "alpn": "",
            "path": "",
            "dest": "23518",
            "xver": 1
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "xtls",
        "xtlsSettings": {
          "alpn": [
            "http/1.1"
          ],
          "serverName": "你的域名",
          "certificates": [
            {
              "certificateFile": "/etc/ssl/private/fullchain.cer",
              "keyFile": "/etc/ssl/private/private.key"
            }
          ]
        },
        "tcpSettings": {
          "header": {
            "type": "none"
          }
        }
      },
      "tag": "inbound-443",
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
    {
      "listen": null,
      "port": 23518,
      "protocol": "trojan",
      "settings": {
        "clients": [
          {
            "password": "ag75wWD7XV",
            "flow": ""
          }
        ],
        "fallbacks": [
          {
            "name": "",
            "alpn": "",
            "path": "",
            "dest": "80",
            "xver": 0
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "none",
        "xtlsSettings": {
          "serverName": "",
          "certificates": [
            {
              "certificateFile": "",
              "keyFile": ""
            }
          ]
        },
        "tcpSettings": {
          "acceptProxyProtocol": true,
          "header": {
            "type": "none"
          }
        }
      },
      "tag": "inbound-23518",
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "transport": null,
  "policy": {
    "system": {
      "statsInboundDownlink": true,
      "statsInboundUplink": true
    }
  },
  "api": {
    "services": [
      "HandlerService",
      "LoggerService",
      "StatsService"
    ],
    "tag": "api"
  },
  "stats": {},
  "reverse": null,
  "fakeDns": null
}
~~~
