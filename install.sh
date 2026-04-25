#!/usr/bin/env bash
# install.sh — install dotfile modules and (optionally) their system deps.
#
# Usage:
#   ./install.sh                  # check deps + install all modules (default: nvim)
#   ./install.sh nvim             # install only nvim module
#   ./install.sh --check          # check dependencies only, no install
#   ./install.sh --skip-deps      # install configs without touching system deps
#   ./install.sh --skip-lazygit   # don't offer to set up lazygit editor
#   ./install.sh --copy nvim      # copy instead of symlink
#   ./install.sh --force nvim     # overwrite existing target without backup
#   ./install.sh --dry-run nvim   # show actions without executing
#   ./install.sh -h               # this help
#
# Idempotent: re-running with the same module is a no-op when the symlink
# already points to the right place.
#
# Compatible with macOS default bash 3.2 (no associative arrays).

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

ALL_MODULES="nvim ghostty"

# resolve_module <name> -> echoes "src_rel:dst_rel", or empty on miss
resolve_module() {
  case "$1" in
    nvim)    echo "nvim:nvim" ;;
    ghostty) echo "ghostty:ghostty" ;;
    *)       echo "" ;;
  esac
}

# ANSI colors (fall back to no-op when not a TTY)
if [ -t 1 ]; then
  C_RESET=$'\033[0m'; C_DIM=$'\033[2m'
  C_RED=$'\033[31m'; C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_BLUE=$'\033[34m'
else
  C_RESET=""; C_DIM=""; C_RED=""; C_GREEN=""; C_YELLOW=""; C_BLUE=""
fi

ok()    { echo "  ${C_GREEN}✓${C_RESET} $*"; }
warn()  { echo "  ${C_YELLOW}!${C_RESET} $*"; }
miss()  { echo "  ${C_RED}✗${C_RESET} $*"; }
note()  { echo "  ${C_DIM}·${C_RESET} $*"; }
head()  { echo "${C_BLUE}==>${C_RESET} $*"; }

# ---------------------------------------------------------------------------
# Flags
# ---------------------------------------------------------------------------
MODE="symlink"     # symlink | copy
FORCE=0
DRY_RUN=0
CHECK_ONLY=0
SKIP_DEPS=0
SKIP_LAZYGIT=0
ARGS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --copy)         MODE="copy"; shift ;;
    --force)        FORCE=1; shift ;;
    --dry-run)      DRY_RUN=1; shift ;;
    --check)        CHECK_ONLY=1; shift ;;
    --skip-deps)    SKIP_DEPS=1; shift ;;
    --skip-lazygit) SKIP_LAZYGIT=1; shift ;;
    -h|--help)
      sed -n '2,17p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    -*)
      echo "Unknown flag: $1" >&2
      exit 1
      ;;
    *) ARGS+=("$1"); shift ;;
  esac
done

if [ ${#ARGS[@]} -eq 0 ]; then
  for m in $ALL_MODULES; do ARGS+=("$m"); done
fi

run() {
  if [ $DRY_RUN -eq 1 ]; then
    echo "[dry-run] $*"
  else
    "$@"
  fi
}

# ---------------------------------------------------------------------------
# OS detection
# ---------------------------------------------------------------------------
detect_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux)  echo "linux" ;;
    *)      echo "other" ;;
  esac
}

OS="$(detect_os)"

# ---------------------------------------------------------------------------
# Dependency check
# ---------------------------------------------------------------------------
# Returns 0 if installed, 1 otherwise. Echoes version when known.
have() { command -v "$1" >/dev/null 2>&1; }

# Required deps (block install if missing): name + check command
# Recommended deps (warn + offer install): editor / git tooling
# Optional deps (note only): md-render extras

REQUIRED_DEPS="nvim git"
RECOMMENDED_DEPS="rg fd lazygit fzf node hx ghostty nerdfont"
OPTIONAL_DEPS="ffmpeg magick mmdc"

# Map binary name -> brew formula / cask name (when they differ).
# Empty string => not installable via brew (handled separately, e.g. mmdc via npm).
brew_formula_for() {
  case "$1" in
    nvim)     echo "neovim" ;;
    rg)       echo "ripgrep" ;;
    node)     echo "node" ;;
    magick)   echo "imagemagick" ;;
    mmdc)     echo "" ;;                                       # via npm
    hx)       echo "helix" ;;
    ghostty)  echo "--cask ghostty" ;;
    nerdfont) echo "--cask font-jetbrains-mono-nerd-font" ;;
    *)        echo "$1" ;;
  esac
}

# nerdfont detection is special: no `nerdfont` binary, check for font file.
have_nerdfont() {
  if [ "$OS" = "macos" ]; then
    [ -f "$HOME/Library/Fonts/JetBrainsMonoNerdFont-Regular.ttf" ] || \
    [ -f "/Library/Fonts/JetBrainsMonoNerdFont-Regular.ttf" ]
  else
    fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"
  fi
}

# ghostty detection: app exists in /Applications on macOS, or `ghostty` in PATH.
have_ghostty() {
  if [ "$OS" = "macos" ]; then
    [ -d "/Applications/Ghostty.app" ] || command -v ghostty >/dev/null 2>&1
  else
    command -v ghostty >/dev/null 2>&1
  fi
}

# Extract a semver-ish version from `<bin> --version` output.
# Uses bash internal regex (no SIGPIPE risk, no external commands).
# Captures both stdout and stderr because some tools (ffmpeg) print to stderr.
get_version() {
  local bin="$1"
  local out=""
  out="$("$bin" --version 2>&1 || true)"
  # First line only
  local first="${out%%$'\n'*}"
  if [[ "$first" =~ ([0-9]+\.[0-9]+(\.[0-9]+)?) ]]; then
    printf '%s' "${BASH_REMATCH[1]}"
  else
    printf '%s' "?"
  fi
}

# nvim version check: returns 0 if ≥ 0.10
nvim_version_ok() {
  if ! have nvim; then return 1; fi
  local v
  v="$(get_version nvim)"
  case "$v" in
    0.10*|0.11*|0.12*|0.13*|0.14*|0.15*|0.16*|0.17*|0.18*|0.19*|0.[2-9]*) return 0 ;;
    [1-9]*) return 0 ;;
    *) return 1 ;;
  esac
}

MISSING_REQUIRED=""
MISSING_RECOMMENDED=""
MISSING_OPTIONAL=""

check_one() {
  local bin="$1" group="$2"
  local present=0 ver=""

  # Specials: not a CLI binary
  case "$bin" in
    nerdfont) have_nerdfont && present=1 ;;
    ghostty)  have_ghostty  && present=1 ;;
    *)        have "$bin"   && present=1 ;;
  esac

  if [ $present -eq 1 ]; then
    case "$bin" in
      nerdfont) ok "JetBrainsMono Nerd Font ${C_DIM}installed${C_RESET}" ;;
      ghostty)  ok "Ghostty ${C_DIM}installed${C_RESET}" ;;
      *)
        ver="$(get_version "$bin")"
        ok "$bin ${C_DIM}${ver}${C_RESET}"
        ;;
    esac
  else
    case "$group" in
      required)    MISSING_REQUIRED="$MISSING_REQUIRED $bin"; miss "$bin (required)" ;;
      recommended) MISSING_RECOMMENDED="$MISSING_RECOMMENDED $bin"; warn "$bin (recommended)" ;;
      optional)    MISSING_OPTIONAL="$MISSING_OPTIONAL $bin"; note "$bin (optional)" ;;
    esac
  fi
}

check_deps() {
  head "Checking dependencies (OS: $OS)"

  for d in $REQUIRED_DEPS; do check_one "$d" required; done

  # nvim version specifically
  if have nvim; then
    if nvim_version_ok; then
      :
    else
      warn "nvim version < 0.10 — md-render.nvim requires 0.10+"
      MISSING_REQUIRED="$MISSING_REQUIRED nvim"
    fi
  fi

  for d in $RECOMMENDED_DEPS; do check_one "$d" recommended; done
  for d in $OPTIONAL_DEPS;    do check_one "$d" optional; done
}

# ---------------------------------------------------------------------------
# Dependency install
# ---------------------------------------------------------------------------
install_deps_macos() {
  local pkgs="$1"
  if ! have brew; then
    warn "Homebrew not found. Install from https://brew.sh"
    echo "    Then re-run: ./install.sh"
    return 1
  fi

  # Split into formulas (brew install) and casks (brew install --cask)
  local formulas="" casks=""
  for bin in $pkgs; do
    local f
    f="$(brew_formula_for "$bin")"
    if [ -z "$f" ]; then
      continue
    fi
    case "$f" in
      "--cask "*) casks="$casks ${f#--cask }" ;;
      *)          formulas="$formulas $f" ;;
    esac
  done

  if [ -n "${formulas// }" ]; then
    echo "Will run: brew install$formulas"
    read -r -p "Proceed? [Y/n] " ans
    case "$ans" in
      n|N|no|NO) echo "Skipping formula install." ;;
      *)
        # shellcheck disable=SC2086
        run brew install $formulas
        ;;
    esac
  fi

  if [ -n "${casks// }" ]; then
    echo "Will run: brew install --cask$casks"
    read -r -p "Proceed? [Y/n] " ans
    case "$ans" in
      n|N|no|NO) echo "Skipping cask install." ;;
      *)
        # shellcheck disable=SC2086
        run brew install --cask $casks
        ;;
    esac
  fi

  # mmdc (mermaid-cli) installs via npm, not brew
  case " $pkgs " in
    *" mmdc "*)
      if have npm; then
        read -r -p "Install @mermaid-js/mermaid-cli via npm? [Y/n] " ans
        case "$ans" in
          n|N|no|NO) echo "Skipping mermaid-cli." ;;
          *) run npm install -g @mermaid-js/mermaid-cli ;;
        esac
      else
        warn "npm not available; skip mermaid-cli install"
      fi
      ;;
  esac
}

install_deps_linux() {
  local pkgs="$1"
  warn "Auto-install on Linux not implemented. Suggested commands:"
  echo "    Debian/Ubuntu:  sudo apt install neovim git ripgrep fd-find fzf nodejs lazygit"
  echo "    Arch:           sudo pacman -S neovim git ripgrep fd fzf nodejs lazygit"
  echo "    Fedora:         sudo dnf install neovim git ripgrep fd-find fzf nodejs lazygit"
  echo
  echo "Missing on this box:$pkgs"
}

install_deps_for() {
  local pkgs="$1"
  if [ -z "${pkgs// }" ]; then return 0; fi

  case "$OS" in
    macos) install_deps_macos "$pkgs" ;;
    linux) install_deps_linux "$pkgs" ;;
    *)     warn "Unknown OS, install manually:$pkgs" ;;
  esac
}

# ---------------------------------------------------------------------------
# Module install (symlink / copy)
# ---------------------------------------------------------------------------
backup_target() {
  target="$1"
  if [ -L "$target" ] || [ -e "$target" ]; then
    if [ $FORCE -eq 1 ]; then
      echo "  removing existing $target (--force)"
      run rm -rf "$target"
    else
      stamp="$(date +%Y%m%d-%H%M%S)"
      backup="${target}.bak.${stamp}"
      echo "  backing up $target -> $backup"
      run mv "$target" "$backup"
    fi
  fi
}

install_module() {
  mod="$1"
  spec="$(resolve_module "$mod")"

  if [ -z "$spec" ]; then
    miss "Unknown module: $mod (known: $ALL_MODULES)"
    return 1
  fi

  src_rel="${spec%%:*}"
  dst_rel="${spec##*:}"
  src_path="$SCRIPT_DIR/$src_rel"
  dst_path="$XDG_CONFIG_HOME/$dst_rel"

  if [ ! -d "$src_path" ]; then
    miss "Source missing: $src_path"
    return 1
  fi

  head "Installing $mod"

  if [ "$MODE" = "symlink" ] && [ -L "$dst_path" ]; then
    current="$(readlink "$dst_path")"
    if [ "$current" = "$src_path" ]; then
      ok "already linked, skipping"
      return 0
    fi
  fi

  backup_target "$dst_path"
  run mkdir -p "$(dirname "$dst_path")"

  case "$MODE" in
    symlink) run ln -s "$src_path" "$dst_path" ;;
    copy)    run cp -R "$src_path" "$dst_path" ;;
  esac

  ok "$MODE: $src_path -> $dst_path"
}

# ---------------------------------------------------------------------------
# lazygit editor setup
# ---------------------------------------------------------------------------
LAZYGIT_CFG="$XDG_CONFIG_HOME/lazygit/config.yml"

setup_lazygit() {
  if [ $SKIP_LAZYGIT -eq 1 ]; then return 0; fi
  if ! have lazygit; then return 0; fi
  if ! have nvim; then return 0; fi

  head "lazygit detected"

  local snippet
  snippet=$(cat <<'YAML'
os:
  edit: "nvim {{filename}}"
  editAtLine: "nvim +{{line}} {{filename}}"
  editAtLineAndWait: "nvim +{{line}} {{filename}}"
  openDirInEditor: "nvim {{dir}}"
YAML
)

  if [ -f "$LAZYGIT_CFG" ]; then
    if grep -qE '^[[:space:]]*edit:[[:space:]]*"?nvim' "$LAZYGIT_CFG"; then
      ok "lazygit already uses nvim, leaving config alone"
      return 0
    fi
    warn "Existing config: $LAZYGIT_CFG"
    echo "    Add this snippet manually to enable nvim:"
    echo
    echo "$snippet" | sed 's/^/      /'
    echo
    return 0
  fi

  read -r -p "Set Neovim as lazygit's default editor? [Y/n] " ans
  case "$ans" in
    n|N|no|NO) note "skipped"; return 0 ;;
  esac

  run mkdir -p "$(dirname "$LAZYGIT_CFG")"
  if [ $DRY_RUN -eq 1 ]; then
    echo "[dry-run] write $LAZYGIT_CFG with nvim editor config"
  else
    printf "%s\n" "$snippet" > "$LAZYGIT_CFG"
  fi
  ok "wrote $LAZYGIT_CFG"
}

# ---------------------------------------------------------------------------
# Main flow
# ---------------------------------------------------------------------------

# 1. Always check deps
check_deps
echo

# 2. --check exits here
if [ $CHECK_ONLY -eq 1 ]; then
  if [ -n "${MISSING_REQUIRED// }" ]; then exit 1; fi
  exit 0
fi

# 3. Required missing? bail (unless --skip-deps)
if [ -n "${MISSING_REQUIRED// }" ] && [ $SKIP_DEPS -eq 0 ]; then
  warn "Required deps missing:${MISSING_REQUIRED}"
  install_deps_for "$MISSING_REQUIRED"
  echo
  if ! have nvim || ! have git; then
    miss "Required deps still missing. Install them, then re-run."
    exit 1
  fi
fi

# 4. Recommended missing? offer install
if [ -n "${MISSING_RECOMMENDED// }" ] && [ $SKIP_DEPS -eq 0 ]; then
  warn "Recommended deps missing:${MISSING_RECOMMENDED}"
  install_deps_for "$MISSING_RECOMMENDED"
  echo
fi

# 5. Optional deps: just hint
if [ -n "${MISSING_OPTIONAL// }" ] && [ $SKIP_DEPS -eq 0 ]; then
  note "Optional (md-render image/Mermaid render):${MISSING_OPTIONAL}"
  note "Install with: ./install.sh --check first to see what's missing"
  echo
fi

# 6. Install modules
for mod in "${ARGS[@]}"; do
  install_module "$mod"
done
echo

# 7. lazygit editor prompt
setup_lazygit

# 8. Optional zsh aliases hint
zsh_aliases="$SCRIPT_DIR/zsh/aliases.zsh"
if [ -f "$zsh_aliases" ]; then
  zshrc="$HOME/.zshrc"
  if [ -f "$zshrc" ] && grep -qF "$zsh_aliases" "$zshrc" 2>/dev/null; then
    :  # already sourced
  else
    head "Optional: shell aliases (gt / lg / v)"
    echo "    Add to your ~/.zshrc:"
    echo
    echo "        source $zsh_aliases"
    echo
    echo "    Not sourced automatically — modifying ~/.zshrc is your call."
  fi
fi

# 9. Final hint
echo
ok "Done."
echo "    Launch nvim: lazy.nvim will sync plugins on first run."
echo "    After :Lazy reports installed, run :checkhealth to verify."
