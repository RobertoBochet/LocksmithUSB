FROM quay.io/fedora/fedora-bootc:45@sha256:f6b5b77567f3d7aadb138c466380bbb8f6a65e2d7d264741f29c5b3bae77543e

LABEL org.opencontainers.image.title="LocksmithUSB"
LABEL org.opencontainers.image.authors="Roberto Bochet <r@robertobochet.me>"
LABEL org.opencontainers.image.licenses="GPL-3.0-only"

ARG HOSTNAME=locksmithusb
ARG PRETTY_NAME=LocksmithUSB

SHELL ["/usr/bin/bash", "-c"]

COPY fs/ /

RUN <<EORUN
# Build script

set -xeuo pipefail

echo "■■■■■ Install packages ■■■■■"
dnf install -y \
    kmscon kmscon-freetype \
    zsh fish \
    tmux screen \
    toolbox \
    vim neovim \
    jq yq \
    git strace \
    tailscale wireguard-tools \
    NetworkManager-wifi \
    iwlegacy-firmware iwlwifi-dvm-firmware iwlwifi-mvm-firmware \
    tcpdump wget rsync \
    iperf3 nmap mtr \
    smartmontools gdisk hdparm parted \
    btrfs-progs snapper \
    testdisk ddrescue pv \
    pciutils nfs-utils sshfs \
    dmidecode usbutils sysstat sysbench \
    htop plocate tree \
    arch-install-scripts \
    cri-tools kubectl \
    cloud-init qemu-guest-agent \
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
sed -i "s/^PRETTY_NAME=.*/PRETTY_NAME=\"$PRETTY_NAME\"/" /usr/lib/os-release

echo "■■■■■ Remove transient files ■■■■■"
rm -rf /run/* /tmp/* || true

echo "■■■■■ Build complete ■■■■■"
EORUN

RUN bootc container lint --no-truncate
