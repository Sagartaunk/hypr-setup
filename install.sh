#!/usr/bin/env bash
# =============================================================================
#  Hyprland Dotfiles Installer
#  
#
#  Usage:
#    ./install.sh           — full install
#    ./install.sh --no-pkgs — skip package install (only copy dotfiles)
#    ./install.sh --pkgs    — install packages only, skip dotfiles
# =============================================================================

set -euo pipefail

# ─── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

log()     { echo -e "${GREEN}[✔]${RESET} $*"; }
info()    { echo -e "${CYAN}[→]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[!]${RESET} $*"; }
error()   { echo -e "${RED}[✘]${RESET} $*" >&2; }
header()  { echo -e "\n${BOLD}${BLUE}━━━ $* ━━━${RESET}\n"; }

# ─── Flags ───────────────────────────────────────────────────────────────────
SKIP_PKGS=false
SKIP_DOTS=false
for arg in "$@"; do
  case "$arg" in
    --no-pkgs) SKIP_PKGS=true ;;
    --pkgs)    SKIP_DOTS=true ;;
    --help|-h)
      echo "Usage: $0 [--no-pkgs | --pkgs]"
      echo "  (no flags)  Full install: packages + dotfiles"
      echo "  --no-pkgs   Dotfiles only"
      echo "  --pkgs      Packages only"
      exit 0 ;;
  esac
done

# ─── Repo root (directory this script lives in) ──────────────────────────────
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTS_DIR="$REPO_DIR/dotfiles"

# ─── Helpers ─────────────────────────────────────────────────────────────────
require_arch() {
  if [[ ! -f /etc/arch-release ]]; then
    error "This script is for Arch Linux only."
    exit 1
  fi
}

require_not_root() {
  if [[ $EUID -eq 0 ]]; then
    error "Don't run this as root. sudo will be called when needed."
    exit 1
  fi
}

confirm() {
  read -rp "$(echo -e "${YELLOW}[?]${RESET} $* [y/N] ")" ans
  [[ "${ans,,}" == "y" ]]
}

# Install yay (AUR helper) if not present
ensure_yay() {
  if command -v yay &>/dev/null; then
    log "yay already installed"
    return
  fi
  info "Installing yay (AUR helper)..."
  sudo pacman -S --needed --noconfirm git base-devel
  local tmp
  tmp=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$tmp/yay"
  (cd "$tmp/yay" && makepkg -si --noconfirm)
  rm -rf "$tmp"
  log "yay installed"
}

# Install a list of packages (pacman + AUR via yay)
install_pkgs() {
  local -n pkgs=$1
  local missing=()
  for pkg in "${pkgs[@]}"; do
    pacman -Qq "$pkg" &>/dev/null || missing+=("$pkg")
  done
  if [[ ${#missing[@]} -eq 0 ]]; then
    log "All packages already installed"
    return
  fi
  info "Installing: ${missing[*]}"
  yay -S --needed --noconfirm "${missing[@]}"
}

# Copy a config dir/file into place, backing up anything already there
deploy_config() {
  local src="$1"   # path inside dotfiles/
  local dest="$2"  # absolute destination path (~/.config/hypr etc.)

  local src_full="$DOTS_DIR/$src"
  if [[ ! -e "$src_full" ]]; then
    warn "Source not found, skipping: $src_full"
    return
  fi

  # Backup existing (never clobber silently)
  if [[ -e "$dest" ]]; then
    local bak="${dest}.bak.$(date +%s)"
    warn "Backing up existing $dest → $bak"
    mv "$dest" "$bak"
  fi

  mkdir -p "$(dirname "$dest")"
  cp -r "$src_full" "$dest"
  log "Copied  $src  →  $dest"
}

# ─── Package Lists ────────────────────────────────────────────────────────────

PKGS_CORE=(
  hyprland          # Wayland compositor
  xdg-desktop-portal-hyprland
  xdg-desktop-portal-gtk
  polkit-kde-agent  # Authentication agent
  qt5-wayland
  qt6-wayland
)

PKGS_TERMINAL=(
  kitty             # Terminal emulator
)

PKGS_BAR=(
  waybar            # Status bar
  ttf-font-awesome  # Icons in waybar
  otf-font-awesome
)

PKGS_LAUNCHER=(
  rofi-wayland      # App launcher (Wayland fork)
)

PKGS_NOTIFICATIONS=(
  dunst             # Notification daemon
  libnotify
)

PKGS_DISPLAY=(
  sddm                    # Login manager
  sddm-sugar-candy-git    # SDDM theme (AUR) — swap if you use a different one
)

PKGS_WALLPAPER=(
  swww              # Wallpaper daemon
)

PKGS_AUDIO=(
  pipewire
  pipewire-alsa
  pipewire-pulse
  pipewire-jack
  wireplumber
  pavucontrol       # Audio GUI
  playerctl         # Media key support
)

PKGS_BLUETOOTH=(
  bluez
  bluez-utils
  blueman
)

PKGS_FILES=(
  thunar
  thunar-archive-plugin
  gvfs
)

PKGS_FONTS=(
  ttf-jetbrains-mono-nerd   # Main coding/terminal font
  ttf-nerd-fonts-symbols
  noto-fonts
  noto-fonts-emoji
)

PKGS_TOOLS=(
  brightnessctl     # Brightness control
  wl-clipboard      # Clipboard
  cliphist          # Clipboard history
  grim              # Screenshot
  slurp             # Screen region select
  swappy            # Screenshot editor
  hyprlock          # Lockscreen
  hypridle          # Idle daemon
  hyprpicker        # Color picker
  network-manager-applet
  nm-connection-editor
  jq                # JSON tool (used in scripts)
  git
  curl
  wget
  unzip
  zip
)

# ─── Install Packages ─────────────────────────────────────────────────────────

install_all_packages() {
  header "Installing Packages"

  ensure_yay

  info "Core Hyprland..."
  install_pkgs PKGS_CORE

  info "Terminal (Kitty)..."
  install_pkgs PKGS_TERMINAL

  info "Waybar..."
  install_pkgs PKGS_BAR

  info "Rofi launcher..."
  install_pkgs PKGS_LAUNCHER

  info "Notifications (Dunst)..."
  install_pkgs PKGS_NOTIFICATIONS

  info "Login manager (SDDM)..."
  install_pkgs PKGS_DISPLAY

  info "Wallpaper (swww)..."
  install_pkgs PKGS_WALLPAPER

  info "Audio (Pipewire)..."
  install_pkgs PKGS_AUDIO

  info "Bluetooth..."
  install_pkgs PKGS_BLUETOOTH

  info "File manager (Thunar)..."
  install_pkgs PKGS_FILES

  info "Fonts..."
  install_pkgs PKGS_FONTS

  info "Tools & utilities..."
  install_pkgs PKGS_TOOLS

  log "All packages installed"
}

# ─── Deploy Dotfiles ──────────────────────────────────────────────────────────

deploy_dotfiles() {
  header "Deploying Dotfiles"

  # Each line: deploy_config "<path-in-dotfiles/>" "<absolute-dest>"
  # dotfiles/ mirrors ~/.config structure directly — no stow packages needed.

  deploy_config "hypr"        "$HOME/.config/hypr"
  deploy_config "kitty"       "$HOME/.config/kitty"
  deploy_config "waybar"      "$HOME/.config/waybar"
  deploy_config "rofi"        "$HOME/.config/rofi"
  deploy_config "dunst"       "$HOME/.config/dunst"
  deploy_config "gtk-3.0"     "$HOME/.config/gtk-3.0"
  deploy_config "gtk-4.0"     "$HOME/.config/gtk-4.0"
  deploy_config "fastfetch"   "$HOME/.config/fastfetch"
  deploy_config "fish"        "$HOME/.config/fish"

  # Shell rc files sit directly in $HOME
  [[ -f "$DOTS_DIR/shell/.zshrc"  ]] && deploy_config "shell/.zshrc"  "$HOME/.zshrc"
  [[ -f "$DOTS_DIR/shell/.bashrc" ]] && deploy_config "shell/.bashrc" "$HOME/.bashrc"

  # Local scripts
  deploy_config "scripts"     "$HOME/.local/bin"

  # Icons / cursors (local installs only — system-wide ones come from packages)
  deploy_config "icons"       "$HOME/.local/share/icons"

  log "All dotfiles deployed"
}

# ─── Post-Install Services & Config ──────────────────────────────────────────

post_install() {
  header "Enabling Services"

  # SDDM
  if systemctl list-unit-files sddm.service &>/dev/null; then
    sudo systemctl enable sddm.service
    log "SDDM enabled"
  fi

  # Bluetooth
  sudo systemctl enable --now bluetooth.service
  log "Bluetooth enabled"

  # NetworkManager
  sudo systemctl enable --now NetworkManager.service
  log "NetworkManager enabled"

  # Pipewire (user service)
  systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service
  log "Pipewire enabled"

  header "GTK / Icon Theme"

  # Apply GTK theme settings (edit these to match your actual theme names)
  GTK_THEME="Your-GTK-Theme-Name"       # ← change this
  ICON_THEME="Your-Icon-Theme-Name"     # ← change this
  CURSOR_THEME="Your-Cursor-Theme"      # ← change this

  if command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.interface gtk-theme       "$GTK_THEME"   2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme      "$ICON_THEME"  2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-theme    "$CURSOR_THEME" 2>/dev/null || true
    log "GTK theme applied"
  fi
}

# ─── Main ─────────────────────────────────────────────────────────────────────

main() {
  require_arch
  require_not_root

  echo -e "${BOLD}${CYAN}"
  echo "  ██╗  ██╗██╗   ██╗██████╗ ██████╗ "
  echo "  ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗"
  echo "  ███████║ ╚████╔╝ ██████╔╝██████╔╝"
  echo "  ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗"
  echo "  ██║  ██║   ██║   ██║     ██║  ██║"
  echo "  ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝"
  echo -e "${RESET}"
  echo -e "  ${BOLD}Hyprland Dotfiles Installer${RESET}"
  echo -e "  Repo: $REPO_DIR\n"

  if ! confirm "Ready to install? This will modify your system."; then
    echo "Aborted."
    exit 0
  fi

  $SKIP_PKGS || install_all_packages
  $SKIP_DOTS || deploy_dotfiles
  $SKIP_DOTS || post_install

  header "Done!"
  log "Installation complete."
  echo -e "\n${YELLOW}Next steps:${RESET}"
  echo "  1. Log out and select Hyprland at SDDM"
  echo "  2. If anything looks off, check the logs:"
  echo "     journalctl --user -xe"
  echo "  3. Waybar / Dunst / Rofi configs live in ~/.config/"
  echo ""
}

main "$@"
