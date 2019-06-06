##################################################
# History
##################################################

# History size
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# zmv -W '*.js' '*.ts'
autoload -Uz zmv

# Set word divider
autoload -Uz select-word-style && select-word-style default

# Share history among terminal
setopt share_history

# Don't leave duplicate commands in history
setopt hist_ignore_all_dups

# Don't remain commands begening with space in history
setopt hist_ignore_space

# Strip space in history
setopt hist_reduce_blanks

##################################################
# Complition
##################################################

fpath=(~/.zsh/completions $fpath)

# Enable complition
autoload -Uz compinit && compinit

# Complete case-insentitively
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Not complete current directory after ../
zstyle ':completion:*' ignore-parents parent pwd ..

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
chpwd() { ls -ltr }

# Extended glob expansion
setopt extended_glob

##################################################
# Others (uncategorized)
##################################################

# Don't exit by ^D
setopt ignore_eof

# '#' is recognized as comment
setopt interactive_comments

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
  $GOPATH/bin \
  /usr/local/bin \
  /usr/local/go/bin \
  /usr/local/kubebuilder/bin \
  ${KREW_ROOT:-$HOME/.krew}/bin \
  $path \
)

##################################################
# Prompt 
##################################################

autoload -Uz vcs_info
setopt prompt_subst

zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr '%F{yellow}!'
zstyle ':vcs_info:git:*' stagedstr '%F{red}+'
zstyle ':vcs_info:*' formats ' on %c%u%b'
zstyle ':vcs_info:*' actionformats ' on %c%u%s:%b|%a'

# Workaround to update vsc_info for each command
# https://github.com/olivierverdier/zsh-git-prompt/issues/55#issuecomment-77427039
precmd () {
    vcs_info
    PROMPT="# %F{cyan}%n%f in %B%F{blue}%~%f%b${vcs_info_msg_0_} %F{white}[%*]%f
%(?.%{$fg[green]%}.%{$fg[red]%})%B❯%b %{${reset_color}%}"
}

PROMPT="# %F{cyan}%n%f in %B%F{blue}%~%f%b${vcs_info_msg_0_} %F{white}[%*]%f
%(?.%{$fg[green]%}.%{$fg[red]%})%B❯%b %{${reset_color}%}"

# prevent from disappearing history prompt(^R) on updating every seconds
# https://unix.stackexchange.com/questions/347182/zle-reset-prompt-prevents-browsing-history-with-arrow-keys
TMOUT=1
TRAPALRM() {
    case "$WIDGET" in
        expand-or-complete|self-insert|up-line-or-beginning-search|down-line-or-beginning-search|backward-delete-char|.history-incremental-search-backward|.history-incremental-search-forward)
            :
            ;;

        *)
            zle reset-prompt
            ;;
    esac
}
     
##################################################
# Aliases
##################################################

alias -g L='| less'
alias -g G='| grep'

alias sudo='sudo ' # enable completion after sudo

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias ls="ls -G"
alias ll="ls -l"
alias la="ls -la"

alias mkdir='mkdir -p'

alias g='git'
alias gad='git add'
alias gbr='git branch'
alias gco='git checkout'
alias glg='git log --graph --oneline --decorate --all'
alias gld='git log --pretty=format:"%h %ad %s" --date=short --all'
alias gst='git status'

##################################################
# Golang
##################################################

export GOPATH=$HOME/go

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
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

##################################################
# Kubernetes
##################################################

# kubectl
source <(kubectl completion zsh)
alias k=kubectl
complete -o default -F __start_kubectl k

### gcloud

# The next line updates PATH for the Google Cloud SDK.
if [ -f '$HOME/google-cloud-sdk/path.zsh.inc' ]; then
    . '$HOME/google-cloud-sdk/path.zsh.inc'
fi

# The next line enables shell command completion for gcloud.
if [ -f '$HOME/google-cloud-sdk/completion.zsh.inc' ]; then
    . '$HOME/google-cloud-sdk/completion.zsh.inc';
fi

