# zyzh2002/caddy_naiveproxy

![build](https://github.com/zyzh2002/caddy_naiveproxy/actions/workflows/build.yml/badge.svg)
![docker](https://github.com/zyzh2002/caddy_naiveproxy/actions/workflows/docker.yml/badge.svg)

Caddy with the following extensions (NaiveProxy/forwardproxy is no longer included):

- [caddy-dns/cloudflare](https://github.com/caddy-dns/cloudflare)
- [caddy-dns/alidns](https://github.com/caddy-dns/alidns)
- [mholt/caddy-l4](https://github.com/mholt/caddy-l4) (TCP/UDP layer-4 routing)

## Download

```bash
wget -O /usr/bin/caddy https://github.com/zyzh2002/caddy_naiveproxy/releases/latest/download/caddy_amd64 # amd64

wget -O /usr/bin/caddy https://github.com/zyzh2002/caddy_naiveproxy/releases/latest/download/caddy_arm64 # arm64
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

## Building and publishing

Releases, not commits to protected main, are the authoritative distribution
source. The historical caddy_amd64 and caddy_arm64 binaries in the root of
the repository are **not automatically updated**. Use the GitHub Release
download URLs above for current binaries.

- ci.yml validates both architectures on relevant pull requests.
- build.yml checks upstream stable Caddy Releases every six hours. When a
  matching complete GitHub Release is missing, it builds both architectures,
  publishes Docker Hub images (latest and version-specific tags), and only
  then uploads caddy_amd64, caddy_arm64 and SHA256SUMS to the versioned
  caddy-vX.Y.Z GitHub Release. A main-branch build configuration change or
  manual run forces a rebuild.
- docker.yml can manually republish Docker Hub images from a GitHub Release
  (latest by default), without recompiling Caddy.

Docker Hub publishing requires DOCKERHUB_USERNAME and DOCKERHUB_TOKEN secrets.
The GitHub Release uses the built-in GITHUB_TOKEN with contents:write permission.
No PERSONAL_ACCESS_TOKEN or direct push to protected main is required.

To build manually, run bash build.sh; set CADDY_VERSION=vX.Y.Z to pin a
specific upstream release. GitHub may delay or disable scheduled workflows
after 60 days of repository inactivity.

The project retains its previous repository and image names for compatibility,
but NaiveProxy/forwardproxy is removed. caddy-l4 remains a third-party module.
