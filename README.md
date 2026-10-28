# zyzh2002/caddy_naiveproxy

![build](https://github.com/zyzh2002/caddy_naiveproxy/actions/workflows/build.yml/badge.svg)
![docker](https://github.com/zyzh2002/caddy_naiveproxy/actions/workflows/docker.yml/badge.svg)

Caddy with the following extensions (NaiveProxy/forwardproxy is no longer included):

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

Run `bash build.sh` with a current Go toolchain to build `caddy_amd64`
and `caddy_arm64`. The build includes `caddy-l4` in both architectures and
verifies that the `layer4` app is registered in the native amd64 executable.
Set `CADDY_VERSION=vX.Y.Z` to build a specific upstream Caddy release tag.

The workflows have separate responsibilities:

- `ci.yml`: builds both architectures on pull requests touching build and CI
  configuration (no publication).
- `build.yml`: checks [Caddy upstream releases](https://github.com/caddyserver/caddy/releases)
  **every six hours** (UTC minute 37), builds only if the published binary
  version differs from the upstream latest stable release **or** is missing
  `layer4`, and commits updated binaries to `main`. Pushes changing
  `build.sh` or `build.yml`, and manual workflow runs, force a rebuild.
  Builds use the exact release tag returned by the GitHub Releases API.
- `docker.yml`: publishes `shell20021020/caddynaive:latest` for
  `linux/amd64` and `linux/arm64` after the binary changes reach `main`
  (or when manually triggered).

This is **polling**, not an instant cross-repository release webhook.
GitHub's `release` event only observes releases in the repository where the
workflow runs. GitHub may delay scheduled jobs, and automatically disables
scheduled workflows in public repositories after **60 days of inactivity**.
If that happens, re-enable the `build` workflow in the repository Actions tab.

Build and binary-publishing use the short-lived `GITHUB_TOKEN` with
`contents: write` and `actions: write` permissions. No personal access token
is required. After a successful binary commit, `build.yml` dispatches
`docker.yml` explicitly because pushes made with `GITHUB_TOKEN` do not
automatically trigger other `push` workflows. Docker Hub publication still
requires the `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets.
If the protected `main` branch rejects GitHub Actions pushes, adjust the
branch permissions or switch to a release-asset-based distribution workflow.

Repository and image names remain unchanged for compatibility. This
repository no longer includes NaiveProxy/forwardproxy. `caddy-l4` is an
experimental third-party module with APIs that may change.

