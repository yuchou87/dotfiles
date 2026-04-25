# Shell setup for the terminal toolchain installed by yuchou87/dotfiles.
# To enable, add this line to your ~/.zshrc:
#
#   source ~/Github/yuchou87/dotfiles/zsh/aliases.zsh
#
# This file is intentionally NOT auto-sourced — modifying ~/.zshrc is
# disruptive and hard to undo. You opt in once, manually.

# =========================
# Aliases
# =========================

alias gt='ghostty'         # terminal
alias lg='lazygit'         # git TUI
alias v='nvim'             # editor
# (`hx` is already the Helix binary name — no alias needed.)

# =========================
# fzf integration (Ctrl-R history, Ctrl-T file picker, Alt-C dir cd)
# =========================
#
# fzf installs the binary but its shell scripts must be sourced explicitly.
# We pick the brew prefix dynamically so this works on Apple Silicon
# (/opt/homebrew) and Intel (/usr/local).

if command -v fzf >/dev/null 2>&1 && command -v brew >/dev/null 2>&1; then
  __fzf_shell="$(brew --prefix 2>/dev/null)/opt/fzf/shell"
  if [[ -d "$__fzf_shell" ]]; then
    [[ -f "$__fzf_shell/key-bindings.zsh" ]] && source "$__fzf_shell/key-bindings.zsh"
    [[ -f "$__fzf_shell/completion.zsh"   ]] && source "$__fzf_shell/completion.zsh"
  fi
  unset __fzf_shell
fi

# =========================
# fd as fzf's source (faster, gitignore-aware, follows symlinks)
# =========================

if command -v fd >/dev/null 2>&1; then
  # Default file source for fzf (used by `fzf` invoked alone)
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

  # Ctrl-T file picker
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_CTRL_T_OPTS='--preview "head -200 {}" --preview-window=right:60%:wrap'

  # Alt-C directory picker
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

  # Ctrl-R history search (default behavior fine, just polish UI)
  export FZF_CTRL_R_OPTS='--reverse --height=40%'
fi
