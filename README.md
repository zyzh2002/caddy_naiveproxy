# zyzh2002/caddy_naiveproxy

![build](https://github.com/zyzh2002/caddy_naiveproxy/actions/workflows/build.yml/badge.svg)
![docker](https://github.com/zyzh2002/caddy_naiveproxy/actions/workflows/docker.yml/badge.svg)

caddy, build with:

- [klzgrad/forwardproxy](https://github.com/klzgrad/forwardproxy)
- [caddy-dns/cloudflare](https://github.com/caddy-dns/cloudflare)
- [caddy-dns/alidns](https://github.com/caddy-dns/alidns)
- [mholt/caddy-l4](https://github.com/mholt/caddy-l4) (TCP/UDP layer-4 routing)

## Download

```bash
wget -O /usr/bin/caddy https://raw.githubusercontent.com/zyzh2002/caddy_naiveproxy/main/caddy_amd64 # amd64

wget -O /usr/bin/caddy https://raw.githubusercontent.com/zyzh2002/caddy_naiveproxy/main/caddy_arm64 # arm64
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

Run `bash build.sh` with a current Go toolchain to produce `caddy_amd64` and
`caddy_arm64`. The script includes `caddy-l4` in both architectures and checks
for the `layer4` app in the native (amd64) executable. Test a downloaded build
with `caddy list-modules | grep '^layer4'`.

GitHub Actions checks builds on pull requests that change `build.sh` or its
workflow. It rebuilds every Friday, on relevant pushes to `main`, and when
manually dispatched. The workflow commits changed binaries to `main`; that
commit triggers the Docker workflow to publish `shell20021020/caddynaive:latest`
for amd64 and arm64.

For publishing, configure repository secrets `PERSONAL_ACCESS_TOKEN`
(with permission to push to the protected `main` branch),
`DOCKERHUB_USERNAME`, and `DOCKERHUB_TOKEN`. A PAT is deliberately used for
the binary commit because pushes performed with `GITHUB_TOKEN` do **not**
trigger downstream `push` workflows. The workflows never publish on a PR.

Note: `caddy-l4` is an experimental third-party plugin, and its interfaces
may change. The Docker image and repository binaries are not updated by
this source-only change until the Actions build succeeds on `main`.
