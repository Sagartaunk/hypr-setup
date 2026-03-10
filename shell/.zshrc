# -------------------------
# BASIC ZSH SETUP
# -------------------------
setopt prompt_subst
setopt autocd
setopt correct
setopt no_beep
# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_space
# -------------------------
# PROMPT (CLEAN ARROW)
# -------------------------
autoload -Uz colors && colors
PROMPT='%F{cyan}➜%f %F{white}%~%f '
# Root prompt (just in case)
PROMPT2='%F{red}➜%f '
# -------------------------
# FASTFETCH ON START
# -------------------------
fastfetch
# -------------------------
# COMPLETION (FAST)
# -------------------------
autoload -Uz compinit
compinit -C
# -------------------------
# ALIASES (OPTIONAL)
# -------------------------
alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -lah'
alias grep='grep --color=auto'
