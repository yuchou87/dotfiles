#!/usr/bin/env bash
# install.sh — symlink dotfile modules into ~/.config (or copy with --copy).
#
# Usage:
#   ./install.sh                  # symlink all modules (default: nvim)
#   ./install.sh nvim             # symlink only nvim
#   ./install.sh --copy nvim      # copy instead of symlink (no live updates)
#   ./install.sh --force nvim     # overwrite existing target without backup
#   ./install.sh --dry-run nvim   # show actions without executing
#
# Idempotent: re-running with the same module is a no-op when the symlink
# already points to the right place.
#
# Compatible with macOS default bash 3.2 (no associative arrays).

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

ALL_MODULES="nvim"

# resolve_module <name> -> echoes "src_rel:dst_rel", or empty on miss
resolve_module() {
  case "$1" in
    nvim)  echo "nvim:nvim" ;;
    *)     echo "" ;;
  esac
}

MODE="symlink"   # symlink | copy
FORCE=0
DRY_RUN=0
ARGS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --copy)    MODE="copy";  shift ;;
    --force)   FORCE=1;       shift ;;
    --dry-run) DRY_RUN=1;     shift ;;
    -h|--help)
      sed -n '2,15p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    -*)
      echo "Unknown flag: $1" >&2
      exit 1
      ;;
    *) ARGS+=("$1"); shift ;;
  esac
done

# Default to all modules when none specified
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
    echo "Unknown module: $mod (known: $ALL_MODULES)" >&2
    return 1
  fi

  src_rel="${spec%%:*}"
  dst_rel="${spec##*:}"
  src_path="$SCRIPT_DIR/$src_rel"
  dst_path="$XDG_CONFIG_HOME/$dst_rel"

  if [ ! -d "$src_path" ]; then
    echo "Source missing: $src_path" >&2
    return 1
  fi

  echo "==> $mod"

  # Idempotency: skip if already correctly symlinked
  if [ "$MODE" = "symlink" ] && [ -L "$dst_path" ]; then
    current="$(readlink "$dst_path")"
    if [ "$current" = "$src_path" ]; then
      echo "  already linked, skipping"
      return 0
    fi
  fi

  backup_target "$dst_path"
  run mkdir -p "$(dirname "$dst_path")"

  case "$MODE" in
    symlink) run ln -s "$src_path" "$dst_path" ;;
    copy)    run cp -R "$src_path" "$dst_path" ;;
  esac

  echo "  $MODE: $src_path -> $dst_path"
}

for mod in "${ARGS[@]}"; do
  install_module "$mod"
done

echo
echo "Done. Launch nvim and let lazy.nvim sync plugins on first run."
echo "After :Lazy reports all installed, run :checkhealth to verify."
