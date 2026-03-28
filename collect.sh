#!/usr/bin/env bash
# =============================================================================
#  collect.sh — Harvest your live configs into dotfiles/ for backup/restore
#
#  Run this on your CURRENT machine whenever you want to snapshot your configs.
#  It copies everything into dotfiles/ mirroring the target path structure so
#  install.sh can just cp them straight back into place.
#
#  Usage:
#    ./collect.sh
# =============================================================================

set -euo pipefail

GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'
BOLD='\033[1m'; RESET='\033[0m'

log()  { echo -e "${GREEN}[✔]${RESET} $*"; }
info() { echo -e "${CYAN}[→]${RESET} $*"; }
warn() { echo -e "${YELLOW}[!]${RESET} $*"; }

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTS="$REPO_DIR"

# ─── Helper: copy a dir into dotfiles/ ───────────────────────────────────────
collect() {
  local src="$1"
  local dest_name="$2"
  local dest="$DOTS/$dest_name"

  if [[ ! -e "$src" ]]; then
    warn "Not found, skipping: $src"
    return
  fi

  rm -rf "$dest"
  mkdir -p "$(dirname "$dest")"
  cp -r "$src" "$dest"
  log "$src  →  dotfiles/$dest_name"
}

# ─── Helper: copy a single file into dotfiles/ ───────────────────────────────
collect_file() {
  local src="$1"
  local dest_path="$2"
  local dest="$DOTS/$dest_path"

  if [[ ! -f "$src" ]]; then
    warn "Not found, skipping: $src"
    return
  fi

  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  log "$src  →  dotfiles/$dest_path"
}

echo -e "\n${BOLD}${CYAN}Collecting dotfiles into repo...${RESET}\n"

mkdir -p "$DOTS"

# ─── Hyprland ─────────────────────────────────────────────────────────────────
collect "$HOME/.config/hypr"            hypr

# ─── Kitty ────────────────────────────────────────────────────────────────────
collect "$HOME/.config/kitty"           kitty

# ─── Waybar ───────────────────────────────────────────────────────────────────
collect "$HOME/.config/waybar"          waybar

# ─── Rofi ─────────────────────────────────────────────────────────────────────
collect "$HOME/.config/rofi"            rofi

# ─── Dunst ────────────────────────────────────────────────────────────────────
collect "$HOME/.config/dunst"           dunst

# ─── GTK ──────────────────────────────────────────────────────────────────────
collect "$HOME/.config/gtk-3.0"         gtk-3.0
collect "$HOME/.config/gtk-4.0"         gtk-4.0
collect_file "$HOME/.gtkrc-2.0"         "shell/.gtkrc-2.0"

# ─── Shell rc ─────────────────────────────────────────────────────────────────
collect_file "$HOME/.zshrc"             "shell/.zshrc"
collect_file "$HOME/.bashrc"            "shell/.bashrc"

# ─── Greetd ───────────────────────────────────────────────────────────────────
collect "/etc/greetd"                   greetd
collect_file "$HOME/.bash_profile"      "shell/.bash_profile"

# ─── Fish (if used) ───────────────────────────────────────────────────────────
collect "$HOME/.config/fish"            fish

# ─── Fastfetch / Neofetch ─────────────────────────────────────────────────────
collect "$HOME/.config/fastfetch"       fastfetch
collect "$HOME/.config/neofetch"        neofetch

# ─── Personal scripts ─────────────────────────────────────────────────────────
collect "$HOME/.local/bin"              scripts

# ─── Local icon / cursor themes ───────────────────────────────────────────────
# Only grabs themes installed locally (not system-wide pacman ones).
# Comment out if you have nothing custom in ~/.local/share/icons.
collect "$HOME/.local/share/icons"      icons

# ─── Wallpapers ───────────────────────────────────────────────────────────────
# Uncomment if you want wallpapers in the repo (can get large):
# collect "$HOME/Pictures/wallpapers"   wallpapers

echo -e "\n${GREEN}${BOLD}Done!${RESET} Configs saved to: ${CYAN}dotfiles/${RESET}\n"
echo "Review what was collected:"
echo "  ls dotfiles/"
echo ""
echo "Then commit and push:"
echo "  git add ."
echo "  git commit -m 'chore: sync dotfiles'"
echo "  git push"
echo ""
