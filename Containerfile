FROM quay.io/fedora/fedora-bootc:41@sha256:8422f122a1567759c5dd5dcda2007e0ff8c01c1dfd67c4146364196c8e078e4c

LABEL org.opencontainers.image.title="LocksmithUSB"
LABEL org.opencontainers.image.authors="Roberto Bochet <r@robertobochet.me>"
LABEL org.opencontainers.image.licenses="GPL-3.0-only"

ARG HOSTNAME=locksmithusb

SHELL ["/usr/bin/bash", "-c"]

COPY fs/ /

RUN <<EORUN
# Build script

set -xeuo pipefail

echo "■■■■■ Install packages ■■■■■"
dnf install -y \
    tailscale \
    wireguard-tools \
    NetworkManager-wifi iwlegacy-firmware iwlwifi-dvm-firmware iwlwifi-mvm-firmware \
    cloud-init qemu-guest-agent \
    zsh fish \
    tmux screen \
    vim neovim jq yq \
    terminus-fonts-console \
    rsync tcpdump wget git strace \
    htop plocate tree \
    btrfs-progs snapper \
    smartmontools gdisk \
    pciutils nfs-utils \
    arch-install-scripts \
    cri-tools kubectl \
    toolbox \
    cowsay figlet lolcat

echo "■■■■■ DNF clean up ■■■■■"
dnf clean all
rm -rf /var/cache/* /var/log/* /var/lib/dnf

echo "■■■■■ General tasks ■■■■■"
cat <<EOF > /etc/hosts
127.0.0.1   $HOSTNAME
::1         $HOSTNAME
EOF
echo "$HOSTNAME" > /etc/hostname

echo "■■■■■ Build complete ■■■■■"
EORUN

RUN bootc container lint --no-truncate
