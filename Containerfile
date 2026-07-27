FROM quay.io/fedora/fedora-bootc:45@sha256:d46877839ebff4db0e3064859fab45de80964e21ed0664fea0785d8a2d3db4e8

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
    kmscon kmscon-freetype \
    tailscale \
    wireguard-tools \
    NetworkManager-wifi iwlegacy-firmware iwlwifi-dvm-firmware iwlwifi-mvm-firmware \
    cloud-init qemu-guest-agent \
    zsh fish \
    tmux screen \
    vim neovim jq yq \
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

echo "■■■■■ Install fonts ■■■■■"
mkdir -p /usr/share/fonts/meslo-nerd-font
curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.tar.xz \
    | tar xJ -C /usr/share/fonts/meslo-nerd-font --no-same-owner

echo "■■■■■ General tasks ■■■■■"
cat <<EOF > /etc/hosts
127.0.0.1   $HOSTNAME
::1         $HOSTNAME
EOF
echo "$HOSTNAME" > /etc/hostname

echo "■■■■■ Remove transient files ■■■■■"
rm -rf /run/* /tmp/* || true

echo "■■■■■ Build complete ■■■■■"
EORUN

RUN bootc container lint --no-truncate
