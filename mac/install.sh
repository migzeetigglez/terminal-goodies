#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config/terminal_goodies_backups/$(date +%Y%m%d-%H%M%S)"

backup_copy() {
  local src="$1"
  local dest="$2"

  if [[ -e "$dest" ]]; then
    local backup_path="$BACKUP_DIR/${dest#$HOME/}"
    mkdir -p "$(dirname "$backup_path")"
    cp -p "$dest" "$backup_path"
  fi

  mkdir -p "$(dirname "$dest")"
  cp -p "$src" "$dest"
}

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required. Install it from https://brew.sh, then rerun this script." >&2
  exit 1
fi

brew install fish starship neofetch kitty chafa imagemagick

mkdir -p "$HOME/.local/bin"
backup_copy "$SCRIPT_DIR/bin/terminal-theme" "$HOME/.local/bin/terminal-theme"
chmod +x "$HOME/.local/bin/terminal-theme"

mkdir -p "$HOME/.config/terminal-goodies/profiles"
rm -rf "$HOME/.config/terminal-goodies/profiles/outlawstar"
rm -rf "$HOME/.config/terminal-goodies/profiles/weyland"
cp -R "$SCRIPT_DIR/profiles/outlawstar" "$HOME/.config/terminal-goodies/profiles/"
cp -R "$SCRIPT_DIR/profiles/weyland" "$HOME/.config/terminal-goodies/profiles/"

backup_copy "$SCRIPT_DIR/zsh/.zshrc" "$HOME/.zshrc"
backup_copy "$SCRIPT_DIR/zsh/starship.toml" "$HOME/.config/starship.toml"

backup_copy "$SCRIPT_DIR/fish/config.fish" "$HOME/.config/fish/config.fish"
backup_copy "$SCRIPT_DIR/fish/fish_variables" "$HOME/.config/fish/fish_variables"
backup_copy "$SCRIPT_DIR/fish/functions/fish_prompt.fish" "$HOME/.config/fish/functions/fish_prompt.fish"
backup_copy "$SCRIPT_DIR/fish/functions/fish_right_prompt.fish" "$HOME/.config/fish/functions/fish_right_prompt.fish"

backup_copy "$SCRIPT_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
backup_copy "$SCRIPT_DIR/kitty/theme.conf" "$HOME/.config/kitty/theme.conf"

backup_copy "$SCRIPT_DIR/neofetch/config.conf" "$HOME/.config/neofetch/config.conf"
backup_copy "$SCRIPT_DIR/neofetch/outlawstar.png" "$HOME/.config/neofetch/outlawstar.png"
backup_copy "$SCRIPT_DIR/neofetch/weyland-yutani.png" "$HOME/.config/neofetch/weyland-yutani.png"
backup_copy "$SCRIPT_DIR/neofetch/weyland-yutani-login.png" "$HOME/.config/neofetch/weyland-yutani-login.png"
backup_copy "$SCRIPT_DIR/neofetch/leo_ascii" "$HOME/.config/neofetch/leo_ascii"
backup_copy "$SCRIPT_DIR/neofetch/ds_dot_ascii" "$HOME/.config/neofetch/ds_dot_ascii"
backup_copy "$SCRIPT_DIR/neofetch/shrek_ascii" "$HOME/.config/neofetch/shrek_ascii"
backup_copy "$SCRIPT_DIR/neofetch/dark_souls_ascii" "$HOME/.config/neofetch/dark_souls_ascii"

if [[ "$(dscl . -read "/Users/$USER" UserShell 2>/dev/null || true)" != *"/bin/zsh"* ]]; then
  echo "Setting login shell to /bin/zsh. macOS may ask for your password."
  chsh -s /bin/zsh
fi

"$HOME/.local/bin/terminal-theme" outlawstar

echo "Installed mac terminal configs."
echo "Backups, if any, were written to: $BACKUP_DIR"
