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

# Enable complition
autoload -Uz compinit && compinit

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
chpwd() { ls -ltrG }

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

git_branch() {
  local branches branch
  branches=$(git --no-pager branch -vv) &&
  branch=$(echo "$branches" | fzf +m) &&
  git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}
zle -N git_branch
bindkey '^B' git_branch

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
# Plugins (zplug)
##################################################

export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug "b4b4r07/enhancd", use:init.sh
zplug "mafredri/zsh-async", from:"github", use:"async.zsh"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-syntax-highlighting"
zplug load

##################################################
# PATH
##################################################

path=( \
  $HOME/.local/bin(N-/) \
  /usr/local/bin(N-/) \
  $path \
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
setopt prompt_subst

zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr '!'
zstyle ':vcs_info:git:*' stagedstr '!'
zstyle ':vcs_info:*' formats '%b' '%c%u'
zstyle ':vcs_info:*' actionformats '%b' '%c%u<%a>'

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
        if [ -n "$vcs_info_msg_1_" ]; then
            vsc_info=" on %B%F{magenta} ${vcs_info_msg_0_}*%f%b"
        else
            vsc_info=" on %B%F{green} ${vcs_info_msg_0_}%f%b"
        fi
    else
        vsc_info=""
    fi

    echo "
%F{245}#%f %B%F{214}%n%f%b in %B%F{cyan}%~%f%b${vsc_info}${venv_info} ${took}
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
# Aliases
##################################################

alias -g L='| less'
alias -g G='| grep'

alias sudo='sudo ' # enable completion after sudo
alias watch='watch ' # enable alias after watch

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias ls="ls -G"
alias ll="ls -l"
alias la="ls -la"

alias mkdir='mkdir -p'

alias g='git'
alias gad='git add'
alias gaa='git add --all'
alias gbr='git branch'
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

##################################################
# Node
##################################################

export NVM_DIR="$HOME/.nvm"

# asynchronously load nvm because nvm.sh is so slow (about 1~ sec)
# https://github.com/nvm-sh/nvm/issues/539#issuecomment-403661578
function load_nvm() {
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
}

# Initialize worker
async_start_worker nvm_worker -n
async_register_callback nvm_worker load_nvm
async_job nvm_worker sleep 0.1

##################################################
# Python
##################################################

# Virtualenvwrapper
if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
    export WORKON_HOME=$HOME/.virtualenvs
    export VIRTUALENVWRAPPER_SCRIPT=/usr/local/bin/virtualenvwrapper.sh
    source /usr/local/bin/virtualenvwrapper_lazy.sh
fi

# pyenv (Python version management)
PYENV_ROOT="$HOME/.pyenv"
if [ -d $PYENV_ROOT ]; then
  path=($PYENV_ROOT/bin(N-/) $path)
  eval "$(pyenv init -)"
fi

##################################################
# Kubernetes
##################################################

path=( \
  /usr/local/kubebuilder/bin(N-/) \
  ${KREW_ROOT:-$HOME/.krew}/bin(N-/) \
  $path \
)

# kubectl
source <(kubectl completion zsh)
alias k=kubectl
complete -o default -F __start_kubectl k

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
