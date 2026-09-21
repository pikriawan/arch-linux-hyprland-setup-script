#!/usr/bin/env bash

set -euo pipefail

version="1.0"

# Update and install packages
sudo pacman -Syu --noconfirm

sudo pacman -S --needed --noconfirm \
    alacritty \
    amberol \
    baobab \
    base-devel \
    bash-completion \
    bluetui \
    brightnessctl \
    btop \
    cliphist \
    decibels \
    espeak-ng \
    fastfetch \
    fd \
    file-roller \
    firefox \
    flatpak \
    fzf \
    git \
    gnome-calculator \
    gnome-calendar \
    gnome-characters \
    gnome-disk-utility \
    gnome-keyring \
    gnome-text-editor \
    grim \
    gvfs-mtp \
    hypridle \
    hyprland \
    hyprlock \
    hyprpaper \
    hyprpicker \
    hyprpolkitagent \
    hyprshutdown \
    hyprsunset \
    jq \
    loupe \
    ly \
    mako \
    man-db \
    nautilus \
    neovim \
    networkmanager \
    nodejs \
    noto-fonts \
    noto-fonts-cjk \
    noto-fonts-emoji \
    npm \
    papers \
    pipewire \
    pipewire-jack \
    pipewire-pulse \
    plymouth \
    qt5-wayland \
    qt6-wayland \
    ripgrep \
    rofi \
    showtime \
    slurp \
    snapshot \
    speech-dispatcher \
    sushi \
    tmux \
    tree \
    tree-sitter-cli \
    ttf-jetbrains-mono \
    ttf-jetbrains-mono-nerd \
    ttf-material-symbols-variable \
    ttf-noto-nerd \
    waybar \
    wget \
    wiremix \
    wireplumber \
    xdg-desktop-portal-gnome \
    xdg-desktop-portal-hyprland

# Configure plymouth
sudo sed -i '/^HOOKS=/ { /plymouth/! s/\bsystemd\b/& plymouth/; }' /etc/mkinitcpio.conf
sudo mkinitcpio -P

# Configure bash
rm "$HOME/.bashrc"
cat > "$HOME/.bashrc" <<'EOF'
#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

export PATH="$HOME/.local/bin:$PATH"
EOF

mkdir -p "$HOME/.tmp"
cd "$HOME/.tmp"

# Install yay
if ! pacman -Qi yay &>/dev/null; then
    if [[ ! -d yay ]]; then
        git clone https://aur.archlinux.org/yay.git
    fi

    cd yay
    makepkg -si --needed --noconfirm
    cd ..
fi

# Copy config files
if [[ ! -d .config ]]; then
    if [[ ! -f .config.tar.gz ]]; then
        curl -fL "https://github.com/pikriawan/arch-linux-install-script/releases/download/v${version}/default.config.tar.gz" -o .config.tar.gz
    fi

    tar -xvzf .config.tar.gz
fi

for i in .config/*; do
    rm -rf "$HOME/$i"
    cp -r $i "$HOME/$i"
done

# Copy opt files
if [[ ! -d opt ]]; then
    if [[ ! -f opt.tar.gz ]]; then
        curl -fL "https://github.com/pikriawan/arch-linux-install-script/releases/download/v${version}/opt.tar.gz" -o opt.tar.gz
    fi

    tar -xvzf opt.tar.gz
fi

rm -rf "$HOME/.local/opt"
cp -r opt "$HOME/.local/opt"

# Copy bin files
if [[ ! -d bin ]]; then
    if [[ ! -f bin.tar.gz ]]; then
        curl -fL "https://github.com/pikriawan/arch-linux-install-script/releases/download/v${version}/bin.tar.gz" -o bin.tar.gz
    fi

    tar -xvzf bin.tar.gz
fi

rm -rf "$HOME/.local/bin"
cp -r bin "$HOME/.local/bin"

# Initialize theme
bash -c "$HOME/.local/opt/theme-manager/theme-manager init"

# Configure speech-dispatcher
spd-conf -ucn

# Enable services
sudo systemctl enable bluetooth.service
sudo systemctl enable ly@tty1.service

# Cleanup
cd "$HOME"
rm -rf "$HOME/.tmp"

echo "Installation completed successfully. Please restart your computer."
