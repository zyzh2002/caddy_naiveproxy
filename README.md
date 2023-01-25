# zyzh2002/caddy_naiveproxy

![build](https://github.com/zyzh2002/caddy_naiveproxy/actions/workflows/build.yml/badge.svg)
![docker](https://github.com/zyzh2002/caddy_naiveproxy/actions/workflows/docker.yml/badge.svg)

caddy, build with:

- [klzgrad/forwardproxy](https://github.com/klzgrad/forwardproxy)
- [caddy-dns/cloudflare](https://github.com/caddy-dns/cloudflare)
- [caddy-dns/alidns](https://github.com/caddy-dns/alidns)

## Download

```bash
wget -O /usr/bin/caddy https://github.com/zyzh2002/caddy/raw/main/caddy_amd64 # amd64

wget -O /usr/bin/caddy https://github.com/zyzh2002/caddy/raw/main/caddy_arm64 # arm64
```

 ## systemd unit file
 ~~~systemd
 [Unit]
Description=Caddy
Documentation=https://caddyserver.com/docs/
After=network.target network-online.target
Requires=network-online.target

[Service]
User=root
Group=root
ExecStart=/usr/bin/caddy run --environ --config /etc/caddy/config.json
ExecReload=/usr/bin/caddy reload --config /etc/caddy/config.json
TimeoutStopSec=5s
LimitNOFILE=1048576
LimitNPROC=512
PrivateTmp=true
ProtectSystem=full
AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
~~~
