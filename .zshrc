##################################################
# History
##################################################

# History size
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Share history among terminal
setopt share_history

# Don't leave duplicate commands in history
setopt hist_ignore_all_dups

# Don't remain commands begening with space in history
setopt hist_ignore_space

# Strip space in history
setopt hist_reduce_blanks

function select-history() {
  BUFFER=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER" --prompt="History > ")
  CURSOR=$#BUFFER
}
zle -N select-history
bindkey '^r' select-history

##################################################
# Completion
##################################################

fpath=(~/.zsh/completions $fpath)

# Complete case-insentitively
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Not complete current directory after ../
zstyle ':completion:*' ignore-parents parent pwd ..

# Highlight selected completion
zstyle ':completion:*' menu select

# Complete after sudo
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
                   /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin

# Complete process name along with ps
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'

##################################################
# Directory transition
##################################################

# cd only with derectory name
setopt auto_cd

# auto pushd on cd
setopt auto_pushd

# Ignore duplicate directory with pushd
setopt pushd_ignore_dups

# Correect comand typo
setopt correct

# Run ls after cd
# chpwd() { ls -ltrG }

# Extended glob expansion
setopt extended_glob


##################################################
# fzf
##################################################

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

ghq_repo() {
    local dir
    dir=$(ghq list > /dev/null | fzf-tmux --reverse +m) &&
    cd $(ghq root)/$dir
}

zle -N ghq_repo
bindkey '^G' ghq_repo

gbr() {
  local branches branch
  branches=$(git --no-pager branch -vv) &&
  branch=$(echo "$branches" | fzf +m) &&
  git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}

##################################################
# Others (uncategorized)
##################################################

# Don't exit by ^D
setopt ignore_eof

# '#' is recognized as comment
setopt interactive_comments

# Set word divider
autoload -Uz select-word-style && select-word-style default

# / is used as word divider, so ^W delete a directory
zstyle ':zle:*' word-chars " /=;@:{},|"
zstyle ':zle:*' word-style unspecified

# ^R => search bachward
# ^S => search forward
setopt no_flow_control
bindkey "^S" history-incremental-search-forward

# Copy stdout to clipboard with C
# http://mollifier.hatenablog.com/entry/20100317/p1
if which pbcopy >/dev/null 2>&1 ; then
    # Mac
    alias -g C='| pbcopy'
elif which xsel >/dev/null 2>&1 ; then
    # Linux
    alias -g C='| xsel --input --clipboard'
elif which putclip >/dev/null 2>&1 ; then
    # Cygwin
    alias -g C='| putclip'
fi

# zmv -W '*.js' '*.ts'
autoload -Uz zmv

##################################################
# Plugins
##################################################

ZSH_PLUGIN_HOME=${ZSH_PLUGIN_HOME:-$HOME/.local/share/zsh/plugins}

fpath=(
  $ZSH_PLUGIN_HOME/zsh-completions/src(N-/) \
  /opt/homebrew/share/zsh/site-functions(N-/) \
  /usr/local/share/zsh-completions(N-/) \
  $fpath
)

autoload -Uz compinit
compinit -C -d ~/.zcompdump

[ -r "$ZSH_PLUGIN_HOME/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
  source "$ZSH_PLUGIN_HOME/zsh-autosuggestions/zsh-autosuggestions.zsh"

[ -r "$ZSH_PLUGIN_HOME/zsh-vimode-visual/zsh-vimode-visual.plugin.zsh" ] && \
  source "$ZSH_PLUGIN_HOME/zsh-vimode-visual/zsh-vimode-visual.plugin.zsh"

##################################################
# PATH
##################################################

path=( \
  $HOME/.local/bin(N-/) \
  $path \
  /usr/local/share/git-core/contrib/diff-highlight(N-/) \
  /usr/local/bin(N-/) \
  $HOME/.bun/bin \
)

##################################################
# ls color
##################################################

export LSCOLORS='gxfxcxdxbxegedabagacad'
export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

##################################################
# Prompt 
##################################################

autoload -Uz vcs_info
autoload -Uz terminfo
setopt prompt_subst

zstyle ':vcs_info:git:*' check-for-changes false
zstyle ':vcs_info:*' formats '%b'
zstyle ':vcs_info:*' actionformats '%b<%a>'

construct_prompt() {
    # Workaround to update vsc_info for each command
    # https://github.com/olivierverdier/zsh-git-prompt/issues/55#issuecomment-77427039
    vcs_info

    if [ -n "$VIRTUAL_ENV" ]; then
         pyver=$(python -V | cut -d" " -f2)
         venv=$(basename $VIRTUAL_ENV)
         venv_info=" on %B%F{yellow}$venv:$pyver%f%b"
    fi

    # timer is not set when starting terminal
    elapsed=$(($SECONDS - ${timer:-$SECONDS}))
    if [ $elapsed -ge 3 ]; then
        took="took %B%F{yellow}${elapsed}sec%f%b"
    else
        took=""
    fi

    if [ -n "$vcs_info_msg_0_" ]; then
        vsc_info=" on %B%F{green} ${vcs_info_msg_0_}%f%b"
    else
        vsc_info=""
    fi

    # Required nerd-fonts
    # https://github.com/ryanoasis/nerd-fonts
    echo "
$ZLE_MODE %B%F{cyan}%~%f%b${vsc_info}${venv_info} ${took}
%(?.%{$fg[green]%}.%{$fg[red]%})➜ %{${reset_color}%}"
}

preexec() {
    timer=$SECONDS
}

precmd () {
    PROMPT=`construct_prompt`
    unset timer
}

PROMPT=`construct_prompt`

##################################################
# ZLE (Zsh Line Editor)
##################################################

bindkey -v
bindkey -M viins 'jj' vi-cmd-mode
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^B' backward-char
bindkey -M viins '^D' delete-char-or-list
bindkey -M viins '^E' end-of-line
bindkey -M viins '^F' forward-char
bindkey -M viins '^H' backward-delete-char
bindkey -M viins '^N' down-line-or-history
bindkey -M viins '^P' up-line-or-history

bindkey -M viins '^r' select-history
bindkey -M viins '^G' ghq_repo

# CHEVRON_RIGHT="\ue0b0" # Requires Powerline Font
CIRCLE_RIGHT="\ue0b4" # Requires Hack Nerd Font

function zle-keymap-select zle-line-init zle-line-finish
{
    case $KEYMAP in
        main|viins)
            ZLE_MODE="%B%K{cyan}%F{white} INS %f%k%b%F{cyan}${CIRCLE_RIGHT}%f"
            ;;
        vicmd)
            ZLE_MODE="%K{white}%F{black} NRM %f%k%F{white}${CIRCLE_RIGHT}%f"
            ;;
        vivis|vivli)
            ZLE_MODE="%B%K{214}%F{white} VIS %f%k%b%F{214}${CIRCLE_RIGHT}%f%f"
            ;;
    esac
    PROMPT=`construct_prompt`
    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-line-finish
zle -N zle-keymap-select
zle -N edit-command-line

     
##################################################
# Aliases
##################################################

alias -g L='| less'
alias -g G='| grep'

alias sudo='sudo ' # enable completion after sudo
alias watch='watch ' # enable alias after watch

alias tm='tmux'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias ls="ls -Gh"
alias ll="ls -lh"
alias la="ls -lah"

alias mkdir='mkdir -p'

alias g='git'
alias gad='git add'
alias gaa='git add --all'
alias gco='git checkout'
alias gcm='git commit'
alias glg='git log --graph --oneline --decorate --all'
alias gld='git log --pretty=format:"%h %ad %s" --date=short --all'
alias gst='git status'

##################################################
# Golang
##################################################

export GOPATH=$HOME/go

path=(
  $GOPATH/bin(N-/) \
  /usr/local/go/bin(N-/) \
  $path
)

if which goenv >/dev/null 2>&1 ; then
  eval "$(goenv init -)"
fi

##################################################
# Node
##################################################

export VOLTA_HOME="$HOME/.volta"
path=(
  $VOLTA_HOME/bin(N-/) \
  $path
)

# bun completions
[ -s "/Users/yokoishi/.bun/_bun" ] && source "/Users/yokoishi/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
. "/Users/yokoishi/.deno/env"


##################################################
# Claude code
##################################################
#alias claude="$HOME/.claude/local/claude"
#
#path=(
#  $HOME/.claude/local(N-/) \
#  $path
#)
eval "$(mise activate zsh)"

[ -r "$ZSH_PLUGIN_HOME/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
  source "$ZSH_PLUGIN_HOME/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

[[ -d ~/.rbenv  ]] && \
  export PATH=${HOME}/.rbenv/bin:${PATH} && \
  eval "$(rbenv init -)"

##################################################
# MySql
##################################################

path=(
  /usr/local/opt/mysql-client/bin(N-/) \
  $path
)

##################################################
# Kubernetes
##################################################

path=( \
  /usr/local/kubebuilder/bin(N-/) \
  ${KREW_ROOT:-$HOME/.krew}/bin(N-/) \
  $path \
)

# kubectl
if which kubectl >/dev/null 2>&1 ; then
  source <(kubectl completion zsh)
  alias k=kubectl
  compdef __start_kubectl k
fi

##################################################
# Google Cloud Platform
##################################################

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then
    . "$HOME/google-cloud-sdk/path.zsh.inc"
fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then
    . "$HOME/google-cloud-sdk/completion.zsh.inc"
fi
