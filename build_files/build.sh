#!/bin/bash

set -ouex pipefail

dnf5 -y remove aurora-plymouth aurora-backgrounds aurora-cli-logos aurora-fastfetch kcm_ublue

dnf5 -y swap --repo=copr:copr.fedorainfracloud.org:ublue-os:packages aurora-logos bluefin-logos

dnf5 -y install --repo=copr:copr.fedorainfracloud.org:ublue-os:packages bluefin-backgrounds bluefin-cli-logos bluefin-fastfetch bluefin-plymouth

dnf5 -y install papirus-icon-theme

ln -sf /usr/share/icons/Papirus/64x64/apps/start-here-fedora.svg /usr/share/icons/hicolor/scalable/apps/start-here.svg

ln -sf /usr/share/backgrounds/bluefin/08-bluefin-day.jxl /usr/share/backgrounds/default.png
ln -sf /usr/share/backgrounds/bluefin/08-bluefin-night.jxl /usr/share/backgrounds/default-dark.png

ln -sf /usr/share/backgrounds/bluefin/11-bluefin.xml /usr/share/backgrounds/default.xml

# /usr/share/sddm/themes/01-breeze-fedora/theme.conf uses default.jxl for the background
ln -sf /usr/share/backgrounds/bluefin/10-bluefin-day.jxl /usr/share/backgrounds/default.jxl
ln -sf /usr/share/backgrounds/bluefin/10-bluefin-night.jxl /usr/share/backgrounds/default-dark.jxl

sed -i '/<entry name="launchers" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>applications:systemsettings.desktop,applications:org.kde.dolphin.desktop,applications:kitty.desktop,applications:emacs.desktop<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml

sed -i '/<entry name="favorites" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>applications:systemsettings.desktop,applications:org.kde.dolphin.desktop,applications:org.gnome.Ptyxis.desktop,applications:kitty.desktop,applications:emacs.desktop,applications:org.kde.kate.desktop,applications:io.github.dvlv.boxbuddyrs.desktop,applications:org.kde.kdeconnect.app.desktop,applications:firewall-config.desktop<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.kickoff/contents/config/main.xml

dnf5 -y install emacs zathura zathura-plugins-all kitty neovim gh

dnf5 -y install fira-code-fonts baekmuk-bdf-fonts baekmuk-batang-fonts adobe-source-han-sans-kr-fonts adobe-source-han-serif-kr-fonts google-noto-sans-cjk-fonts google-noto-serif-cjk-fonts google-noto-sans-cjk-vf-fonts google-noto-serif-cjk-vf-fonts google-roboto-fonts google-roboto-mono-fonts

fc-cache -fv

KERNEL_SUFFIX=""

QUALIFIED_KERNEL="$(rpm -qa | grep -P 'kernel-(|'"$KERNEL_SUFFIX"'-)(\d+\.\d+\.\d+)' | sed -E 's/kernel-(|'"$KERNEL_SUFFIX"'-)//')"
/usr/bin/dracut --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible -v --add ostree -f "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"
chmod 0600 "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"
