FROM quay.io/fedora/fedora-bootc:41

LABEL org.opencontainers.image.title="LocksmithUSB"
LABEL org.opencontainers.image.authors="Roberto Bochet <r@robertobochet.me>"
LABEL org.opencontainers.image.licenses="GPL-3.0-only"

ARG HOSTNAME=locksmithusb
ARG SSH_AUTHORIZED_KEYS

ARG TARGETARCH

# Set hostname
RUN echo "$HOSTNAME" > /etc/hostname && \
		echo "127.0.0.1	$HOSTNAME" >> /etc/hosts && \
		echo "::1		$HOSTNAME" >> /etc/hosts

# Setup hardcoded SSH keys
RUN set -eu; mkdir -p /usr/ssh && \
    echo 'AuthorizedKeysFile /usr/ssh/%u.keys .ssh/authorized_keys .ssh/authorized_keys2' >> /etc/ssh/sshd_config.d/30-auth-system.conf
RUN [ -z "$SSH_AUTHORIZED_KEYS" ] || echo "$SSH_AUTHORIZED_KEYS" > /usr/ssh/root.keys

# Install tools
RUN dnf install -y \
        fish terminus-fonts-console \
        vim neovim \
        pciutils nfs-utils gdisk htop tcpdump \
        tree plocate jq yq git \
        NetworkManager-wifi iwlegacy-firmware iwlwifi-dvm-firmware iwlwifi-mvm-firmware \
        arch-install-scripts \
		&& dnf clean all

# Set fish as default shell
RUN usermod -s /usr/bin/fish root

# Set autologin on the tty1 for root
COPY <<'EOF' /etc/systemd/system/getty@tty1.service.d/autologin.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --autologin root %I $TERM
EOF

# Reduce kernel log level printed on tty to warning
RUN echo "kernel.printk=4" > /etc/sysctl.d/99-disable-kernel-print-logs.conf

# Disable ssh password authentication
RUN echo "PasswordAuthentication no" > /etc/ssh/sshd_config.d/10-disable-password-authentication.conf

# Set global environment variables
RUN echo "EDITOR=nvim" >> /etc/environment

# Lint container image
RUN bootc container lint
