# cd
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# eza
alias ls='eza'
# list, size, type, git
alias ll='eza -lbF --git'
# long list, modified date sort
alias llm='eza -lbGd --git --sort=modified'
# all list
alias la='eza -lbhHigUmuSa --time-style=long-iso --git --color-scale'
# all + extended list
alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale'
# one column, just names
alias lS='eza -1'
# tree
alias lt='eza --tree --level=2'


# bat
alias cat='bat'

# others
alias rm='rm -i'
alias mkdir='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'
alias myip='curl ip.appspot.com' # Public facing IP Address