#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update
sudo apt-get install -y live-build debootstrap xorriso squashfs-tools \
  syslinux isolinux syslinux-utils grub-efi-amd64-bin grub-pc-bin mtools dosfstools

mkdir -p lumen-build
cd lumen-build
sudo lb clean --purge 2>/dev/null || true

lb config \
  --distribution bookworm \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --bootloaders "syslinux,grub-efi" \
  --debian-installer live \
  --debian-installer-gui true \
  --archive-areas "main contrib non-free-firmware" \
  --iso-application "Lumen OS Pro" \
  --iso-volume "LUMEN_OS_PRO" \
  --bootappend-live "boot=live components locales=de_DE.UTF-8 keyboard-layouts=de timezone=Europe/Berlin username=lumen hostname=lumen-os"

mkdir -p config/package-lists
cat > config/package-lists/lumen.list.chroot <<'EOF'
xfce4
xfce4-goodies
lightdm
xfce4-whiskermenu-plugin
thunar
xfce4-terminal
arc-theme
papirus-icon-theme
fonts-inter
firefox-esr
firefox-esr-l10n-de
network-manager
network-manager-gnome
locales
console-setup
keyboard-configuration
task-german
task-german-desktop
sudo
gparted
EOF

mkdir -p config/includes.chroot/etc/default
cat > config/includes.chroot/etc/default/keyboard <<'EOF'
XKBMODEL="pc105"
XKBLAYOUT="de"
XKBVARIANT=""
XKBOPTIONS=""
BACKSPACE="guess"
EOF
cat > config/includes.chroot/etc/default/locale <<'EOF'
LANG=de_DE.UTF-8
EOF

mkdir -p config/hooks/normal
cat > config/hooks/normal/0100-locale.hook.chroot <<'EOF'
#!/bin/sh
sed -i 's/^# *de_DE.UTF-8/de_DE.UTF-8/' /etc/locale.gen
locale-gen
EOF
chmod +x config/hooks/normal/0100-locale.hook.chroot

mkdir -p config/includes.installer
cat > config/includes.installer/preseed.cfg <<'EOF'
d-i debian-installer/locale string de_DE.UTF-8
d-i keyboard-configuration/xkb-keymap select de
d-i time/zone string Europe/Berlin
EOF

sudo lb build 2>&1 | tee build.log

ISO=$(ls -1 *.iso | head -n1)
mv "$ISO" lumen-os-pro-amd64.iso
ls -lh lumen-os-pro-amd64.iso
