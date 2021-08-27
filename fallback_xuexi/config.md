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
            "id": "f1f5681e-2b76-4705-969f-d945c1b9fc31",
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
          },
          {
            "name": "",
            "alpn": "",
            "path": "/datevm",
            "dest": "33743",
            "xver": 1
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "xtls",
        "xtlsSettings": {
          "serverName": "你的域名",
          "alpn": [
            "http/1.1"
          ],
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
      "port": 8443,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "7a6698f7-d9d4-4247-8e6e-9b6a4ae20643",
            "alterId": 0
          }
        ],
        "disableInsecureEncryption": false
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
          "serverName": "你的域名",
          "certificates": [
            {
              "certificateFile": "/etc/ssl/private/fullchain.cer",
              "keyFile": "/etc/ssl/private/private.key"
            }
          ]
        },
        "wsSettings": {
          "path": "/datevm",
          "headers": {}
        }
      },
      "tag": "inbound-8443",
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
    },
    {
      "listen": null,
      "port": 33743,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "1eeaf292-a362-4d07-9d54-e75f79eee209",
            "alterId": 0
          }
        ],
        "disableInsecureEncryption": false
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "acceptProxyProtocol": true,
          "path": "/datevm",
          "headers": {}
        }
      },
      "tag": "inbound-33743",
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
