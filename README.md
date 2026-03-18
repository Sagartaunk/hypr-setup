# 🌿 Hyprland Dotfiles

My Arch Linux + Hyprland setup. One command to restore everything on a new machine.

## Stack

| Role | Package |
|------|---------|
| Compositor | Hyprland |
| Terminal | Kitty |
| Bar | Waybar |
| Launcher | Rofi (Wayland) |
| Notifications | Dunst |
| Login manager | SDDM |
| Wallpaper | swww |
| Audio | Pipewire + Wireplumber |
| Lockscreen | hyprlock |
| Idle | hypridle |
| File manager |Nemo|
| Bluetooth | bluez + blueman |

## Fresh Install

On a brand-new Arch system (post `archinstall` or base install):

```bash
git clone https://github.com/sagartaunk/hyprland.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

**Options:**
```
./install.sh           # Full install: packages + configs
./install.sh --no-pkgs # Configs only (skip pacman/yay)
./install.sh --pkgs    # Packages only (skip copying configs)
```

After install: log out and select Hyprland at the SDDM screen.

## Keeping Configs Backed Up

Run this any time you change something:

```bash
./collect.sh
git add .
git commit -m "update configs"
git push
```

`collect.sh` snapshots your live `~/.config/*` dirs into `dotfiles/` automatically.

## dotfiles/ structure

Each folder maps directly to a path under `~/.config/` (or `~/` for shell files):

```
dotfiles/
├── hypr/         → ~/.config/hypr/
├── kitty/        → ~/.config/kitty/
├── waybar/       → ~/.config/waybar/
├── rofi/         → ~/.config/rofi/
├── dunst/        → ~/.config/dunst/
├── gtk-3.0/      → ~/.config/gtk-3.0/
├── gtk-4.0/      → ~/.config/gtk-4.0/
├── fish/         → ~/.config/fish/
├── fastfetch/    → ~/.config/fastfetch/
├── scripts/      → ~/.local/bin/
├── icons/        → ~/.local/share/icons/
└── shell/
    ├── .zshrc    → ~/.zshrc
    └── .bashrc   → ~/.bashrc
```

## Things to Edit Before Using

In `install.sh`, near the bottom of `post_install()`:
```bash
GTK_THEME="Your-GTK-Theme-Name"     # ← your actual GTK theme
ICON_THEME="Your-Icon-Theme-Name"   # ← your actual icon theme
CURSOR_THEME="Your-Cursor-Theme"    # ← your actual cursor theme
```

Also check the `PKGS_DISPLAY` array if you use a specific SDDM theme package.
