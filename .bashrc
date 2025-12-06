#!/bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# Enhanced and refactored for productivity by Claude Code

#######################################################
# INTERACTIVE SHELL CHECK
#######################################################

# If not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

# Store if this is an interactive terminal
iatest=$(expr index "$-" i)

#######################################################
# SOURCE EXTERNAL CONFIGURATIONS
#######################################################

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Enable bash programmable completion features in interactive shells
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Source custom aliases if file exists
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

#######################################################
# SHELL OPTIONS (shopt)
#######################################################

# Check window size after each command and update LINES and COLUMNS
shopt -s checkwinsize

# Append to history instead of overwriting
shopt -s histappend

# Enable extended globbing for advanced pattern matching
shopt -s extglob

# Enable recursive globbing with **
shopt -s globstar 2>/dev/null

# Correct minor spelling errors in cd commands
shopt -s cdspell

# Autocorrect directory names to match a glob
shopt -s dirspell 2>/dev/null

# Enable case-insensitive globbing
shopt -s nocaseglob

#######################################################
# HISTORY CONFIGURATION
#######################################################

# Expand the history size significantly
export HISTFILESIZE=50000
export HISTSIZE=10000

# Don't put duplicate lines or lines starting with space in history
export HISTCONTROL=erasedups:ignoredups:ignorespace

# Ignore common commands in history
export HISTIGNORE="ls:ll:la:cd:pwd:exit:date:clear:history"

# Add timestamps to history
export HISTTIMEFORMAT="%F %T "

# Save and reload history after each command
PROMPT_COMMAND='history -a'

#######################################################
# TERMINAL BEHAVIOR
#######################################################

# Disable the bell
if [[ $iatest > 0 ]]; then
    bind "set bell-style none"
fi

# Allow ctrl-S for history navigation (with ctrl-R)
stty -ixon 2>/dev/null

# Case-insensitive auto-completion
if [[ $iatest > 0 ]]; then
    bind "set completion-ignore-case on"
    bind "set show-all-if-ambiguous on"
    bind "set show-all-if-unmodified on"
    bind "set menu-complete-display-prefix on"
fi

#######################################################
# ENVIRONMENT VARIABLES
#######################################################

# Default editor (prefer vim over nano)
if command -v vim &>/dev/null; then
    export EDITOR=vim
    export VISUAL=vim
elif command -v nano &>/dev/null; then
    export EDITOR=nano
    export VISUAL=nano
fi

# Enable colors for ls and grep
export CLICOLOR=1

# Configure dircolors if available
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# LS_COLORS configuration
export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'

# Colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Colored man pages using less
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;208m' # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[01;44;33m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;111m' # begin underline

# Less options
export LESS='-R -i -M -F -X -S'

#######################################################
# PATH CONFIGURATION
#######################################################

# Add local bin to PATH if not already present
if [ -d "$HOME/.local/bin" ]; then
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) export PATH="$HOME/.local/bin:$PATH" ;;
    esac
fi

# pnpm configuration
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac

#######################################################
# GENERAL ALIASES - FILE OPERATIONS
#######################################################

# Safety aliases for destructive commands
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias ln='ln -i'

# Enhanced ls aliases
alias ls='ls -aFh --color=always'
alias ll='ls -alFh'
alias la='ls -Ah'
alias l='ls -CF'
alias lx='ls -lXBh'    # sort by extension
alias lk='ls -lSrh'    # sort by size
alias lc='ls -lcrh'    # sort by change time
alias lu='ls -lurh'    # sort by access time
alias lr='ls -lRh'     # recursive ls
alias lt='ls -ltrh'    # sort by date
alias lm='ls -alh | more'
alias lw='ls -xAh'
alias labc='ls -lap'
alias lf="ls -l | grep -v '^d'"  # files only
alias ldir="ls -l | grep '^d'"   # directories only

# Navigation aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias cd..='cd ..'
alias home='cd ~'
alias bd='cd "$OLDPWD"'
alias d='cd /home/samirparhi/code'

# Directory operations
alias mkdir='mkdir -pv'
alias rmd='rm -rfv'

# File permissions
alias mx='chmod a+x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

#######################################################
# SYSTEM ALIASES
#######################################################

alias cls='clear'
alias c='clear'
alias h='history'
alias j='jobs -l'

# Common commands
alias da='date "+%Y-%m-%d %A %T %Z"'
alias path='echo -e ${PATH//:/\\n}'
alias now='date "+%T"'
alias nowdate='date "+%Y-%m-%d"'

# Process management
alias ps='ps auxf'
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias psgrep='ps aux | grep -v grep | grep -i -e VSZ -e'
alias psmem='ps auxf | sort -nr -k 4 | head -10'
alias pscpu='ps auxf | sort -nr -k 3 | head -10'
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"

# Disk usage
alias df='df -h'
alias du='du -h'
alias diskspace="du -S | sort -n -r | more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias mountedinfo='df -hT'

# Network
alias ping='ping -c 5'
alias fastping='ping -c 100 -s 2'
alias ports='netstat -tulanp'
alias openports='netstat -nape --inet'
alias listening='lsof -P -i -n'

# System info
alias meminfo='free -m -l -t'
alias cpuinfo='lscpu'

# Package management (apt-based systems)
alias apt-get='sudo apt-get'
alias apt='sudo apt'
alias update='sudo apt update'
alias upgrade='sudo apt upgrade'
alias install='sudo apt install'
alias remove='sudo apt remove'

#######################################################
# PRODUCTIVITY ALIASES
#######################################################

# Grep with color
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Search aliases
alias h='history | grep'
alias p='ps aux | grep'
alias f='find . | grep'

# Count files
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2>/dev/null"

# Check command type
alias checkcommand='type -t'

# Tree command with sensible defaults
if command -v tree &>/dev/null; then
    alias tree='tree -CAhF --dirsfirst'
    alias treed='tree -CAFd'
fi

# Archive shortcuts
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

# Editor shortcuts
alias ebrc='${EDITOR} ~/.bashrc'
alias sbrc='source ~/.bashrc'
alias vbrc='vim ~/.bashrc'

# Quick IP check
alias myip='curl -s ifconfig.me'
alias localip="ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1'"

# SHA checksums
alias sha1='openssl sha1'
alias sha256='openssl sha256'

# Git shortcuts (if git is available)
if command -v git &>/dev/null; then
    alias g='git'
    alias gs='git status'
    alias ga='git add'
    alias gc='git commit'
    alias gp='git push'
    alias gl='git log --oneline --graph --decorate'
    alias gd='git diff'
    alias gco='git checkout'
    alias gb='git branch'
fi

# Docker shortcuts (if docker is available)
if command -v docker &>/dev/null; then
    alias dk='docker'
    alias dkps='docker ps'
    alias dkpsa='docker ps -a'
    alias dki='docker images'
    alias dkrm='docker rm'
    alias dkrmi='docker rmi'
    alias dkstop='docker stop'
fi

# Kubernetes shortcuts (if kubectl is available)
if command -v kubectl &>/dev/null; then
    alias k='kubectl'
    alias kgp='kubectl get pods'
    alias kgpa='kubectl get pods --all-namespaces'
    alias kgs='kubectl get services'
    alias kgd='kubectl get deployments'
    alias kgn='kubectl get nodes'
    alias kga='kubectl get all'
    alias kd='kubectl describe'
    alias kdp='kubectl describe pod'
    alias kds='kubectl describe service'
    alias kl='kubectl logs'
    alias klf='kubectl logs -f'
    alias ke='kubectl exec -it'
    alias ka='kubectl apply -f'
    alias kdel='kubectl delete'
    alias kc='kubectl config'
    alias kcgc='kubectl config get-contexts'
    alias kcuc='kubectl config use-context'
    alias kgpw='kubectl get pods -w'
    alias kgpwide='kubectl get pods -o wide'
    alias kgswide='kubectl get services -o wide'
fi

# Google Cloud (gcloud) shortcuts (if gcloud is available)
if command -v gcloud &>/dev/null; then
    alias gc='gcloud'
    alias gcinit='gcloud init'
    alias gcauth='gcloud auth login'
    alias gclist='gcloud auth list'
    alias gcproj='gcloud config get-value project'
    alias gcsetproj='gcloud config set project'
    alias gccompute='gcloud compute'
    alias gcinstances='gcloud compute instances list'
    alias gcssh='gcloud compute ssh'
    alias gcsql='gcloud sql'
    alias gcstorage='gcloud storage'
    alias gcls='gcloud storage ls'
    alias gcbuckets='gcloud storage buckets list'
    alias gck8s='gcloud container clusters'
    alias gck8slist='gcloud container clusters list'
    alias gck8sget='gcloud container clusters get-credentials'
    alias gcservices='gcloud services list --enabled'
    alias gcregions='gcloud compute regions list'
    alias gczones='gcloud compute zones list'
    alias gcconfig='gcloud config list'
    alias gcconfigs='gcloud config configurations list'
fi

# OpenTofu shortcuts (if tofu is available)
if command -v tofu &>/dev/null; then
    alias tf='tofu'
    alias tfinit='tofu init'
    alias tfplan='tofu plan'
    alias tfapply='tofu apply'
    alias tfdestroy='tofu destroy'
    alias tffmt='tofu fmt'
    alias tfvalidate='tofu validate'
    alias tfoutput='tofu output'
    alias tfshow='tofu show'
    alias tfstate='tofu state'
    alias tflist='tofu state list'
    alias tfworkspace='tofu workspace'
    alias tfws='tofu workspace'
    alias tfwslist='tofu workspace list'
    alias tfwsnew='tofu workspace new'
    alias tfwsselect='tofu workspace select'
    alias tfrefresh='tofu refresh'
    alias tfimport='tofu import'
    alias tftaint='tofu taint'
    alias tfuntaint='tofu untaint'
    alias tfgraph='tofu graph'
    alias tfconsole='tofu console'
fi

# Terraform shortcuts (if terraform is available and tofu is not)
if command -v terraform &>/dev/null && ! command -v tofu &>/dev/null; then
    alias tf='terraform'
    alias tfinit='terraform init'
    alias tfplan='terraform plan'
    alias tfapply='terraform apply'
    alias tfdestroy='terraform destroy'
    alias tffmt='terraform fmt'
    alias tfvalidate='terraform validate'
    alias tfoutput='terraform output'
    alias tfshow='terraform show'
    alias tfstate='terraform state'
    alias tflist='terraform state list'
    alias tfworkspace='terraform workspace'
    alias tfws='terraform workspace'
    alias tfwslist='terraform workspace list'
    alias tfwsnew='terraform workspace new'
    alias tfwsselect='terraform workspace select'
    alias tfrefresh='terraform refresh'
    alias tfimport='terraform import'
    alias tftaint='terraform taint'
    alias tfuntaint='terraform untaint'
    alias tfgraph='terraform graph'
    alias tfconsole='terraform console'
fi

# Add alert for long-running commands
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

#######################################################
# FUNCTIONS - EDITOR
#######################################################

# Use the best available editor
edit() {
    if command -v vim &>/dev/null; then
        vim "$@"
    elif [ "$(type -t jpico)" = "file" ]; then
        jpico -nonotice -linums -nobackups "$@"
    elif command -v nano &>/dev/null; then
        nano -c "$@"
    elif [ "$(type -t pico)" = "file" ]; then
        pico "$@"
    else
        vi "$@"
    fi
}

# Edit with sudo
sedit() {
    if command -v vim &>/dev/null; then
        sudo vim "$@"
    elif [ "$(type -t jpico)" = "file" ]; then
        sudo jpico -nonotice -linums -nobackups "$@"
    elif command -v nano &>/dev/null; then
        sudo nano -c "$@"
    elif [ "$(type -t pico)" = "file" ]; then
        sudo pico "$@"
    else
        sudo vi "$@"
    fi
}

#######################################################
# FUNCTIONS - ARCHIVE EXTRACTION
#######################################################

# Extract any archive type
extract() {
    if [ -z "$1" ]; then
        echo "Usage: extract <archive_file>"
        return 1
    fi

    for archive in "$@"; do
        if [ -f "$archive" ]; then
            case "$archive" in
                *.tar.bz2)   tar xvjf "$archive"    ;;
                *.tar.gz)    tar xvzf "$archive"    ;;
                *.tar.xz)    tar xvJf "$archive"    ;;
                *.bz2)       bunzip2 "$archive"     ;;
                *.rar)       unrar x "$archive"     ;;
                *.gz)        gunzip "$archive"      ;;
                *.tar)       tar xvf "$archive"     ;;
                *.tbz2)      tar xvjf "$archive"    ;;
                *.tgz)       tar xvzf "$archive"    ;;
                *.zip)       unzip "$archive"       ;;
                *.Z)         uncompress "$archive"  ;;
                *.7z)        7z x "$archive"        ;;
                *.xz)        unxz "$archive"        ;;
                *.exe)       cabextract "$archive"  ;;
                *)           echo "extract: '$archive' - unknown archive method" ;;
            esac
        else
            echo "extract: '$archive' - file does not exist"
        fi
    done
}

#######################################################
# FUNCTIONS - SEARCH
#######################################################

# Search for text in all files in the current folder
ftext() {
    if [ -z "$1" ]; then
        echo "Usage: ftext <search_text>"
        return 1
    fi
    grep -iIHrn --color=always "$1" . | less -R
}

# Find and grep combined
findgrep() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: findgrep <file_pattern> <search_text>"
        return 1
    fi
    find . -type f -name "$1" -exec grep -iHn --color=always "$2" {} \;
}

#######################################################
# FUNCTIONS - DIRECTORY NAVIGATION
#######################################################

# Create directory and cd into it
mkdirg() {
    mkdir -p "$1" && cd "$1" || return
}

# Copy file and go to destination
cpg() {
    if [ -d "$2" ]; then
        cp "$1" "$2" && cd "$2" || return
    else
        cp "$1" "$2"
    fi
}

# Move file and go to destination
mvg() {
    if [ -d "$2" ]; then
        mv "$1" "$2" && cd "$2" || return
    else
        mv "$1" "$2"
    fi
}

# Go up N directories (e.g., up 3)
up() {
    local d=""
    local limit="${1:-1}"
    for ((i=1; i <= limit; i++)); do
        d="$d/.."
    done
    d=$(echo "$d" | sed 's/^\///')
    if [ -z "$d" ]; then
        d=..
    fi
    cd "$d" || return
}

# Show the last 2 fields of the working directory
pwdtail() {
    pwd | awk -F/ '{nlast = NF -1;print $nlast"/"$NF}'
}

# Optional: Auto-ls after cd (uncomment if desired)
# cd() {
#     if [ -n "$1" ]; then
#         builtin cd "$@" && ls
#     else
#         builtin cd ~ && ls
#     fi
# }

#######################################################
# FUNCTIONS - SYSTEM INFORMATION
#######################################################

# Detect Linux distribution
distribution() {
    local dtype="unknown"

    # Check for systemd
    if [ -f /etc/os-release ]; then
        dtype=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
    elif [ -r /etc/rc.d/init.d/functions ]; then
        source /etc/rc.d/init.d/functions
        [ "$(type -t passed 2>/dev/null)" == "function" ] && dtype="redhat"
    elif [ -r /etc/rc.status ]; then
        source /etc/rc.status
        [ "$(type -t rc_reset 2>/dev/null)" == "function" ] && dtype="suse"
    elif [ -r /lib/lsb/init-functions ]; then
        source /lib/lsb/init-functions
        [ "$(type -t log_begin_msg 2>/dev/null)" == "function" ] && dtype="debian"
    elif [ -r /etc/init.d/functions.sh ]; then
        source /etc/init.d/functions.sh
        [ "$(type -t ebegin 2>/dev/null)" == "function" ] && dtype="gentoo"
    elif [ -s /etc/mandriva-release ]; then
        dtype="mandriva"
    elif [ -s /etc/slackware-version ]; then
        dtype="slackware"
    fi
    echo "$dtype"
}

# Show OS version
ver() {
    local dtype
    dtype=$(distribution)

    if [ -f /etc/os-release ]; then
        cat /etc/os-release
        uname -a
    elif [ "$dtype" == "redhat" ]; then
        if [ -s /etc/redhat-release ]; then
            cat /etc/redhat-release && uname -a
        else
            cat /etc/issue && uname -a
        fi
    elif [ "$dtype" == "suse" ]; then
        cat /etc/SuSE-release
    elif [ "$dtype" == "debian" ]; then
        lsb_release -a
    elif [ "$dtype" == "gentoo" ]; then
        cat /etc/gentoo-release
    elif [ "$dtype" == "mandriva" ]; then
        cat /etc/mandriva-release
    elif [ "$dtype" == "slackware" ]; then
        cat /etc/slackware-version
    else
        if [ -s /etc/issue ]; then
            cat /etc/issue
        else
            echo "Error: Unknown distribution"
            return 1
        fi
    fi
}

# Show network information
netinfo() {
    echo "--------------- Network Information ---------------"
    if command -v ip &>/dev/null; then
        echo "IP Addresses:"
        ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | while read -r ip; do
            echo "  $ip"
        done
        echo ""
        echo "Network Interfaces:"
        ip link show | grep -E '^[0-9]+:' | awk '{print "  "$2}' | sed 's/:$//'
    else
        /sbin/ifconfig | awk '/inet addr/ {print $2}'
        /sbin/ifconfig | awk '/Bcast/ {print $3}'
        /sbin/ifconfig | awk '/inet addr/ {print $4}'
        /sbin/ifconfig | awk '/HWaddr/ {print $4,$5}'
    fi
    echo "---------------------------------------------------"
}

# Get public and private IP
whatsmyip() {
    echo -n "Internal IP: "
    if command -v ip &>/dev/null; then
        ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -1
    else
        /sbin/ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'
    fi

    echo -n "External IP: "
    curl -s ifconfig.me || wget -qO- ifconfig.me || echo "Unable to determine"
}

#######################################################
# FUNCTIONS - FILE OPERATIONS
#######################################################

# Copy file with progress bar
cpp() {
    set -e
    strace -q -ewrite cp -- "${1}" "${2}" 2>&1 \
    | awk '{
        count += $NF
        if (count % 10 == 0) {
            percent = count / total_size * 100
            printf "%3d%% [", percent
            for (i=0;i<=percent;i++)
                printf "="
            printf ">"
            for (i=percent;i<100;i++)
                printf " "
            printf "]\r"
        }
    }
    END { print "" }' total_size="$(stat -c '%s' "${1}")" count=0
}

# Trim leading and trailing whitespace
trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    echo -n "$var"
}

# ROT13 encoding
rot13() {
    if [ $# -eq 0 ]; then
        tr '[a-m][n-z][A-M][N-Z]' '[n-z][a-m][N-Z][A-M]'
    else
        echo "$*" | tr '[a-m][n-z][A-M][N-Z]' '[n-z][a-m][N-Z][A-M]'
    fi
}

# Create backup of a file
backup() {
    if [ -z "$1" ]; then
        echo "Usage: backup <file>"
        return 1
    fi
    cp "$1"{,.bak-$(date +%Y%m%d-%H%M%S)}
}

# Quick file search
qfind() {
    find . -iname "*$1*"
}

#######################################################
# FUNCTIONS - WEB/SERVER (Optional)
#######################################################

# View Apache logs (if Apache is installed)
apachelog() {
    if [ -f /etc/httpd/conf/httpd.conf ]; then
        cd /var/log/httpd && ls -xAh && multitail --no-repeat -c -s 2 /var/log/httpd/*_log
    elif [ -d /var/log/apache2 ]; then
        cd /var/log/apache2 && ls -xAh && multitail --no-repeat -c -s 2 /var/log/apache2/*.log
    else
        echo "Apache not found"
    fi
}

# Edit Apache config
apacheconfig() {
    if [ -f /etc/httpd/conf/httpd.conf ]; then
        sedit /etc/httpd/conf/httpd.conf
    elif [ -f /etc/apache2/apache2.conf ]; then
        sedit /etc/apache2/apache2.conf
    else
        echo "Error: Apache config file could not be found."
    fi
}

# Edit PHP config
phpconfig() {
    local php_ini_paths=(
        "/etc/php.ini"
        "/etc/php/php.ini"
        "/etc/php5/php.ini"
        "/usr/bin/php5/bin/php.ini"
        "/etc/php5/apache2/php.ini"
        "/etc/php/7.*/apache2/php.ini"
        "/etc/php/8.*/apache2/php.ini"
    )

    for path in "${php_ini_paths[@]}"; do
        if [ -f "$path" ]; then
            sedit "$path"
            return 0
        fi
    done

    echo "Error: php.ini file could not be found."
    echo "Searching for possible locations:"
    sudo updatedb 2>/dev/null && locate php.ini
}

# Edit MySQL config
mysqlconfig() {
    local mysql_cnf_paths=(
        "/etc/my.cnf"
        "/etc/mysql/my.cnf"
        "/usr/local/etc/my.cnf"
        "/usr/bin/mysql/my.cnf"
        "$HOME/my.cnf"
        "$HOME/.my.cnf"
    )

    for path in "${mysql_cnf_paths[@]}"; do
        if [ -f "$path" ]; then
            sedit "$path"
            return 0
        fi
    done

    echo "Error: my.cnf file could not be found."
}

#######################################################
# PROMPT CONFIGURATION
#######################################################

# CPU usage function for prompt
cpu() {
    grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}' | awk '{printf("%.1f\n", $1)}'
}

# Set the custom prompt
__setprompt() {
    local LAST_COMMAND=$? # Must come first!

    # Define colors
    local LIGHTGRAY="\033[0;37m"
    local WHITE="\033[1;37m"
    local BLACK="\033[0;30m"
    local DARKGRAY="\033[1;30m"
    local RED="\033[0;31m"
    local LIGHTRED="\033[1;31m"
    local GREEN="\033[0;32m"
    local LIGHTGREEN="\033[1;32m"
    local BROWN="\033[0;33m"
    local YELLOW="\033[1;33m"
    local BLUE="\033[0;34m"
    local LIGHTBLUE="\033[1;34m"
    local MAGENTA="\033[0;35m"
    local LIGHTMAGENTA="\033[1;35m"
    local CYAN="\033[0;36m"
    local LIGHTCYAN="\033[1;36m"
    local NOCOLOR="\033[0m"

    # Show error exit code if there is one
    if [[ $LAST_COMMAND != 0 ]]; then
        PS1="\[${DARKGRAY}\](\[${LIGHTRED}\]ERROR\[${DARKGRAY}\])-(\[${RED}\]Exit Code \[${LIGHTRED}\]${LAST_COMMAND}\[${DARKGRAY}\])-(\[${RED}\]"

        case $LAST_COMMAND in
            1)   PS1+="General error" ;;
            2)   PS1+="Missing keyword/command/permission" ;;
            126) PS1+="Permission problem or not executable" ;;
            127) PS1+="Command not found" ;;
            128) PS1+="Invalid argument to exit" ;;
            129) PS1+="Fatal error signal 1" ;;
            130) PS1+="Script terminated by Control-C" ;;
            131) PS1+="Fatal error signal 3" ;;
            132) PS1+="Fatal error signal 4" ;;
            133) PS1+="Fatal error signal 5" ;;
            134) PS1+="Fatal error signal 6" ;;
            135) PS1+="Fatal error signal 7" ;;
            136) PS1+="Fatal error signal 8" ;;
            137) PS1+="Fatal error signal 9" ;;
            *)   if [ $LAST_COMMAND -gt 255 ]; then
                     PS1+="Exit status out of range"
                 else
                     PS1+="Unknown error code"
                 fi ;;
        esac
        PS1+="\[${DARKGRAY}\])\[${NOCOLOR}\]\n"
    else
        PS1=""
    fi

    # Date and time - Format: (Fri Dec-5 6:33:10pm)
    PS1+="\[${DARKGRAY}\](\[${CYAN}\]\$(date +%a) \$(date +%b-%-d) "
    PS1+="\[${BLUE}\]\$(date +%-I:%M:%S%P)\[${DARKGRAY}\])-"

    # CPU usage, Jobs count, Network connections - Format: (CPU 3.4%:0:Net 40)
    PS1+="(\[${MAGENTA}\]CPU \$(cpu)%"
    PS1+="\[${DARKGRAY}\]:\[${MAGENTA}\]\j"
    if [ -f /proc/net/tcp ]; then
        PS1+="\[${DARKGRAY}\]:\[${MAGENTA}\]Net \$(awk 'END {print NR-1}' /proc/net/tcp)"
    fi
    PS1+="\[${DARKGRAY}\])-"

    # User and directory - Format: (samirparhi:~/code)
    PS1+="(\[${RED}\]\u\[${DARKGRAY}\]:\[${BROWN}\]\w\[${DARKGRAY}\])-"

    # Total size and file count - Format: (16K:2)
    PS1+="(\[${GREEN}\]\$(/bin/ls -lah 2>/dev/null | /bin/grep -m 1 total | /bin/sed 's/total //' || echo '0')\[${DARKGRAY}\]:"
    PS1+="\[${GREEN}\]\$(/bin/ls -A -1 2>/dev/null | /usr/bin/wc -l)\[${DARKGRAY}\])"

    # Git branch (if in a git repository)
    if command -v git &>/dev/null; then
        local git_branch="\$(git branch 2>/dev/null | grep '^*' | colrm 1 2)"
        PS1+="-(\[${LIGHTCYAN}\]git:\[${LIGHTGREEN}\]${git_branch}\[${DARKGRAY}\])"
    fi

    # New line
    PS1+="\n"

    # Final prompt symbol
    if [[ $EUID -ne 0 ]]; then
        PS1+="\[${GREEN}\]>\[${NOCOLOR}\] "
    else
        PS1+="\[${RED}\]#\[${NOCOLOR}\] "
    fi

    # PS2 for line continuation
    PS2="\[${DARKGRAY}\]>\[${NOCOLOR}\] "

    # PS3 for select
    PS3='Please enter a number from above list: '

    # PS4 for debug
    PS4='\[${DARKGRAY}\]+\[${NOCOLOR}\] '
}

# Set PROMPT_COMMAND to use our custom prompt
PROMPT_COMMAND='__setprompt'

#######################################################
# TERMINAL TITLE CONFIGURATION
#######################################################

# Set terminal title for xterm/rxvt
case "$TERM" in
xterm*|rxvt*)
    # Function to print title
    print_title() {
        local FIRSTPART=""
        local SECONDPART=""

        if [ "$PWD" == "$HOME" ]; then
            FIRSTPART="~"
        elif [ "$PWD" == "/" ]; then
            FIRSTPART="/"
        else
            FIRSTPART="${PWD##*/}"
        fi

        if [[ -n "$__el_LAST_EXECUTED_COMMAND" ]]; then
            if [[ "$__el_LAST_EXECUTED_COMMAND" == sudo* ]]; then
                SECONDPART="${__el_LAST_EXECUTED_COMMAND:5}"
                SECONDPART="${SECONDPART%% *}"
            else
                SECONDPART="${__el_LAST_EXECUTED_COMMAND%% *}"
            fi
            printf "%s: %s" "$FIRSTPART" "$SECONDPART"
        else
            echo "$FIRSTPART"
        fi
    }

    # Update terminal title with current command
    update_tab_command() {
        case "$BASH_COMMAND" in
            *\033]0*|update_*|echo*|printf*|clear*|cd*)
                __el_LAST_EXECUTED_COMMAND=""
                ;;
            *)
                __el_LAST_EXECUTED_COMMAND="${BASH_COMMAND}"
                printf "\033]0;%s\007" "${BASH_COMMAND}"
                ;;
        esac
    }

    # Set up preexec if available
    if ! type -t preexec_functions >/dev/null 2>&1; then
        preexec_functions=()
        trap 'update_tab_command' DEBUG
    else
        preexec_functions+=(update_tab_command)
    fi
    ;;
*)
    ;;
esac

#######################################################
# WELCOME MESSAGE (Optional - comment out if not desired)
#######################################################

# Display system information on login
if [ -t 0 ]; then
    echo -e "\n${GREEN}Welcome to $(hostname)${NOCOLOR}"
    echo -e "${CYAN}Today is $(date '+%A, %B %d, %Y')${NOCOLOR}"
    if command -v uptime &>/dev/null; then
        echo -e "${YELLOW}$(uptime)${NOCOLOR}"
    fi
    if command -v free &>/dev/null; then
        echo -e "${MAGENTA}Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')${NOCOLOR}"
    fi
    echo ""
fi

#######################################################
# CUSTOM USER CONFIGURATIONS
#######################################################

# Add your custom configurations below this line
# Example:
# alias myproject='cd ~/projects/myproject'
# export CUSTOM_VAR="value"

#######################################################
# END OF .bashrc
#######################################################
