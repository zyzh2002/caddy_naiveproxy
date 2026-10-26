#!/usr/bin/env bash
set -euo pipefail

# xcaddy installs into GOPATH/bin, which is not always in PATH.
export PATH="$(go env GOPATH)/bin:${PATH}"
go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest

for arch in amd64 arm64; do
    echo "Building Caddy for linux/${arch}"
    CGO_ENABLED=0 GOOS=linux GOARCH="${arch}" xcaddy build latest \
        --with github.com/caddyserver/forwardproxy@caddy2=github.com/klzgrad/forwardproxy@naive \
        --with github.com/caddy-dns/cloudflare \
        --with github.com/caddy-dns/alidns \
        --with github.com/mholt/caddy-l4 \
        --output "caddy_${arch}"
done

# Catch missing plugin registrations before publishing either binary.
if ! ./caddy_amd64 list-modules | grep -Fx 'layer4' >/dev/null; then
    echo 'Error: caddy-l4 (layer4 app) is missing from the binary' >&2
    exit 1
fi
./caddy_amd64 version
