# macOS zsh config

export SHELL="/bin/zsh"

# Homebrew lives in /opt/homebrew on Apple Silicon and /usr/local on Intel Macs.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(SHELL=/bin/zsh /opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(SHELL=/bin/zsh /usr/local/bin/brew shellenv)"
fi

export PATH="$HOME/.local/bin:$PATH"

if [[ -r "$HOME/.config/terminal-goodies/theme.env" ]]; then
  source "$HOME/.config/terminal-goodies/theme.env"
fi

terminal-theme() {
  command terminal-theme "$@"
  local exit_code=$?

  if (( exit_code == 0 )) && [[ -r "$HOME/.zshrc" ]]; then
    source "$HOME/.zshrc"
    neofetch
  fi

  return $exit_code
}

export EDITOR="${EDITOR:-vim}"
if command -v code >/dev/null 2>&1; then
  export VISUAL="${VISUAL:-code --wait}"
else
  export VISUAL="${VISUAL:-$EDITOR}"
fi

# Starship prompt
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

_terminal_goodies_center() {
  local text="$1"
  local color="${2:-}"
  local reset="${3:-}"
  local width="${4:-${COLUMNS:-80}}"
  local prefix="${5:-}"
  local padding=$(( (width - ${#text}) / 2 ))

  (( width < 40 )) && width=80
  padding=$(( (width - ${#text}) / 2 ))
  (( padding < 0 )) && padding=0
  printf "%s%*s%s%s%s\n" "$prefix" "$padding" "" "$color" "$text" "$reset"
}

_terminal_goodies_block_line() {
  local text="$1"
  local color="$2"
  local reset="$3"
  local width="$4"
  local prefix="$5"
  local block_width="$6"
  local padding=$(( (width - block_width) / 2 ))

  (( padding < 0 )) && padding=0
  printf "%s%*s%s%-*.*s%s\n" "$prefix" "$padding" "" "$color" "$block_width" "$block_width" "$text" "$reset"
}

_terminal_goodies_value() {
  local value="$1"

  if [[ -n "$value" ]]; then
    printf "%s" "$value"
  else
    printf "unknown"
  fi
}

_terminal_goodies_mem() {
  local bytes
  bytes="$(sysctl -n hw.memsize 2>/dev/null)"

  if [[ -n "$bytes" ]]; then
    awk -v bytes="$bytes" 'BEGIN { printf "%.0fGiB", bytes / 1024 / 1024 / 1024 }'
  else
    printf "unknown"
  fi
}

_terminal_goodies_terminal_cols() {
  local cols="${COLUMNS:-0}"
  local tput_cols stty_cols

  tput_cols="$(tput cols 2>/dev/null || true)"
  stty_cols="$(stty size 2>/dev/null | awk '{ print $2 }')"

  [[ "$cols" =~ '^[0-9]+$' ]] || cols=0

  if [[ "$tput_cols" =~ '^[0-9]+$' && "$tput_cols" -gt "$cols" ]]; then
    cols="$tput_cols"
  fi

  if [[ "$stty_cols" =~ '^[0-9]+$' && "$stty_cols" -gt "$cols" ]]; then
    cols="$stty_cols"
  fi

  (( cols > 0 )) || cols=80
  printf "%s" "$cols"
}

_terminal_goodies_uptime() {
  uptime 2>/dev/null | sed -E 's/^.*up[[:space:]]+//; s/,[[:space:]]+[0-9]+ users?.*$//; s/,[[:space:]]+load averages?:.*$//' | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//'
}

_terminal_goodies_chip() {
  local chip
  chip="$(system_profiler SPHardwareDataType 2>/dev/null | awk -F': ' '/Chip|Processor Name/ { print $2; exit }')"

  if [[ -z "$chip" ]]; then
    chip="$(sysctl -n machdep.cpu.brand_string 2>/dev/null)"
  fi

  _terminal_goodies_value "$chip"
}

_terminal_goodies_resolution() {
  local resolution
  resolution="$(system_profiler SPDisplaysDataType 2>/dev/null | awk '/Resolution:/ { print $2 "x" $4; exit }')"
  _terminal_goodies_value "$resolution"
}

_terminal_goodies_weyland_banner() {
  local cols="$1"
  local indent="$2"
  local reset=$'\033[0m'
  local cyan=$'\033[38;2;102;240;200m'
  local dim=$'\033[38;2;65;112;96m'
  local mark_width=80

  _terminal_goodies_center "WEYLAND-YUTANI CORP" "$cyan" "$reset" "$cols" "$indent"
  _terminal_goodies_center "____________________________________________________________" "$dim" "$reset" "$cols" "$indent"
  _terminal_goodies_block_line "   +++++++++++     +++++++++++++    ++++++++    +++++++++++++     +++++++++++" "$cyan" "$reset" "$cols" "$indent" "$mark_width"
  _terminal_goodies_block_line "   ++         ++   ++        ++   ++        ++   ++        ++   ++         ++" "$cyan" "$reset" "$cols" "$indent" "$mark_width"
  _terminal_goodies_block_line "    ++          ++  +++     ++  ++            ++  ++     +++  ++          ++" "$cyan" "$reset" "$cols" "$indent" "$mark_width"
  _terminal_goodies_block_line "      +++         ++  ++++++  ++                ++  ++++++  ++         +++" "$cyan" "$reset" "$cols" "$indent" "$mark_width"
  _terminal_goodies_block_line "        +++         ++  ++  ++        ++++        ++  ++  ++         +++" "$cyan" "$reset" "$cols" "$indent" "$mark_width"
  _terminal_goodies_block_line "          +++         ++  ++        +++  +++        ++  ++         +++" "$cyan" "$reset" "$cols" "$indent" "$mark_width"
  _terminal_goodies_block_line "            +++         ++        ++  ++++  ++        ++         +++" "$cyan" "$reset" "$cols" "$indent" "$mark_width"
  _terminal_goodies_block_line "              +++               ++  +++  +++  ++               +++" "$cyan" "$reset" "$cols" "$indent" "$mark_width"
  _terminal_goodies_block_line "                +++           +++ +++      +++ +++           +++" "$cyan" "$reset" "$cols" "$indent" "$mark_width"
  _terminal_goodies_block_line "                  +++++++++++++  ++++++++++++++  +++++++++++++" "$cyan" "$reset" "$cols" "$indent" "$mark_width"
  _terminal_goodies_center "BUILDING BETTER WORLDS" "$cyan" "$reset" "$cols" "$indent"
  printf "\n"
  _terminal_goodies_center "TOKYO - LONDON - SAN FRANCISCO - SEA OF TRANQUILITY - THEDUS" "$cyan" "$reset" "$cols" "$indent"
  _terminal_goodies_center "============================================================" "$cyan" "$reset" "$cols" "$indent"
  _terminal_goodies_center "LOADING DATA USER INTERFACE" "$dim" "$reset" "$cols" "$indent"
}

_terminal_goodies_weyland_row() {
  local indent="$1"
  local col_width="$2"
  local col1="$3"
  local col2="$4"
  local col3="$5"

  printf "%s%-*.*s  %-*.*s  %-*.*s\n" \
    "$indent" \
    "$col_width" "$col_width" "$col1" \
    "$col_width" "$col_width" "$col2" \
    "$col_width" "$col_width" "$col3"
}

_terminal_goodies_weyland_fetch() {
  local reset=$'\033[0m'
  local cyan=$'\033[38;2;102;240;200m'
  local dim=$'\033[38;2;65;112;96m'
  local amber=$'\033[38;2;215;182;90m'
  local red=$'\033[38;2;195;72;56m'
  local cols="${TERMINAL_GOODIES_WY_PANEL_COLUMNS:-80}"
  local terminal_cols
  local indent_width=0
  local indent=""
  local col_width=$(( (cols - 6) / 3 ))

  terminal_cols="$(_terminal_goodies_terminal_cols)"

  if (( terminal_cols < cols )); then
    printf "${red}WY DISPLAY ERROR:${reset} TERMINAL WIDTH BELOW ${cols} COLUMNS\n"
    printf "${cyan}STATUS:${reset} EXPAND TERMINAL AND RE-RUN NEOFETCH\n\n"
    return 0
  fi

  indent_width=$(( (terminal_cols - cols) / 2 ))
  (( indent_width < 0 )) && indent_width=0
  indent="$(printf '%*s' "$indent_width" '')"

  col_width=$(( (cols - 6) / 3 ))
  (( col_width > 30 )) && col_width=30
  (( col_width < 22 )) && col_width=22

  _terminal_goodies_weyland_banner "$cols" "$indent"

  printf "\n"
  printf "%s%s%s\n\n" "$indent" "${dim}$(printf '%*s' "$cols" '' | tr ' ' '-')${reset}" ""

  local os kernel packages shell_name ui terminal_name model chip gpu memory uptime_text resolution
  os="$(sw_vers -productName 2>/dev/null) $(sw_vers -productVersion 2>/dev/null) $(uname -m 2>/dev/null)"
  kernel="$(uname -sr 2>/dev/null)"
  packages="$(brew list --formula 2>/dev/null | wc -l | tr -d ' ') (brew)"
  shell_name="$(basename "${SHELL:-zsh}") ${ZSH_VERSION:-}"
  ui="Quartz Compositor"
  terminal_name="${TERM_PROGRAM:-${TERM:-unknown}}"
  model="$(sysctl -n hw.model 2>/dev/null)"
  chip="$(_terminal_goodies_chip)"
  gpu="$chip"
  memory="$(_terminal_goodies_mem)"
  uptime_text="$(_terminal_goodies_uptime)"
  resolution="$(_terminal_goodies_resolution)"

  printf "%s%s%-*s%s  %s%-*s%s  %s%-*s%s\n" \
    "$indent" \
    "$amber" "$col_width" "SYS ----------------" "$reset" \
    "$amber" "$col_width" "DISPLAY ------------" "$reset" \
    "$amber" "$col_width" "ASSET --------------" "$reset"
  _terminal_goodies_weyland_row "$indent" "$col_width" "OS    $os" "UI    $ui" "MODEL $model"
  _terminal_goodies_weyland_row "$indent" "$col_width" "KERN  $kernel" "TERM  $terminal_name" "CPU   $chip"
  _terminal_goodies_weyland_row "$indent" "$col_width" "PKG   $packages" "RES   $resolution" "GPU   $gpu"
  _terminal_goodies_weyland_row "$indent" "$col_width" "SH    $shell_name" "" "MEM   $memory"
  _terminal_goodies_weyland_row "$indent" "$col_width" "" "" "UP    $uptime_text"
  printf "\n"

  printf "%s${red}SPECIAL ORDER 937:${reset} CREW EXPENDABLE\n" "$indent"
  printf "%s${cyan}STATUS:${reset} PROCEED\n\n" "$indent"
}

neofetch() {
  local image="${TERMINAL_GOODIES_NEOFETCH_IMAGE:-$HOME/.config/neofetch/outlawstar.png}"

  if (( $# == 0 )) && [[ "${TERMINAL_GOODIES_THEME:-}" == "weyland" ]]; then
    _terminal_goodies_weyland_fetch
  elif (( $# == 0 )) && [[ -f "$image" ]]; then
    if [[ -n "$KITTY_PID" || -n "$KITTY_WINDOW_ID" || "$TERM" == "xterm-kitty" ]]; then
      command neofetch --kitty "$image" --size "${TERMINAL_GOODIES_NEOFETCH_KITTY_SIZE:-820px}" --crop_mode none --gap "${TERMINAL_GOODIES_NEOFETCH_KITTY_GAP:--12}"
    elif command -v chafa >/dev/null 2>&1; then
      local image_lines info_lines
      image_lines="$(mktemp)"
      info_lines="$(mktemp)"

      chafa \
        --format symbols \
        --symbols half+block+space \
        --colors full \
        --dither none \
        --work 9 \
        --size "${TERMINAL_GOODIES_NEOFETCH_IMAGE_SIZE:-52x34}" \
        "$image" > "$image_lines"
      command neofetch --backend off > "$info_lines"
      paste -d ' ' "$image_lines" "$info_lines"
      rm -f "$image_lines" "$info_lines"
    else
      command neofetch
    fi
  else
    command neofetch "$@"
  fi
}

# Show system info once when a new interactive terminal session starts.
if [[ -o interactive && -z "$TERMINAL_GOODIES_NEOFETCH_SHOWN" ]] && command -v neofetch >/dev/null 2>&1; then
  export TERMINAL_GOODIES_NEOFETCH_SHOWN=1
  neofetch
fi
