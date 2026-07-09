#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

alias bathealth='echo 1 | sudo tee /sys/bus/wmi/drivers/acer-wmi-battery/health_mode'
alias Datamount='sudo mount -t ntfs3 -o force /dev/sda1 /Data/'
alias Winmount='sudo mount -t ntfs3 -o force /dev/disk/by-uuid/01DBF62529A5B4B0 /WinDir/'
alias pkw='pkill waybar ; waybar & disown;'
alias ls='eza'
alias tt='dolphin . & disown'
alias prime-run='__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia'
export LIBVIRT_DEFAULT_URI="qemu:///system"
export PATH="/opt/cuda/bin/:$HOME/.local/bin:$PATH"

# Don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it
shopt -s histappend

# Huge history size
HISTSIZE=10000
HISTFILESIZE=20000

# After each command, append to the history file and read it back
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
eval "$(starship init bash)"
export PS1="\[\e[32m\]\u@\h \[\e[34m\]\w \$ \[\e[0m\]" # Simple fallback color prompt

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"
