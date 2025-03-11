###########
### FZF ###
###########
# https://github.com/junegunn/fzf
# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
# fzf parameters used in all widgets - configure layout and wrapped the preview results (useful in large command rendering)
export FZF_DEFAULT_OPTS="--preview 'bat --color=always {}'"
# CTRL + R: put the selected history command in the preview window - "{}" will be replaced by item selected in fzf execution runtime
export FZF_CTRL_R_OPTS="--preview 'echo {}'"
# ALT + C: set "fd-find" as directory search engine instead of "find" and exclude "venv|virtualenv|.git" of the results during searching
export FZF_ALT_C_COMMAND="fd --type directory --exclude venv --exclude virtualenv --exclude .git"
# ALT + C: put the tree command output based on item selected
export FZF_ALT_C_OPTS="--preview 'tree -C {}'"
# CTRL + T: set "fd-find" as search engine instead of "find" and exclude "venv|virtualenv|.git" for the results
export FZF_CTRL_T_COMMAND="fd --exclude venv --exclude virtualenv --exclude .git"
# CTRL + T: put the file content if item select is a file, or put tree command output if item selected is directory
export FZF_CTRL_T_OPTS="--preview '[ -d {} ] && tree -C {} || bat --color=always --style=numbers {}'"

###############
### FZF-TAB ###
###############
# https://github.com/Aloxaf/fzf-tab
autoload -U compinit; compinit
source $HOME/.config/fzf-tab/fzf-tab.plugin.zsh
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# custom fzf flags
# NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'


#######################
### BAT as MANPAGER ###
#######################
# Configure bat as the manpager
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# Alternative simpler version if the above doesn't work well
# export MANPAGER="bat -l man -p"

# Create batman function for better compatibility
batman() {
    bat -l man -p "$(man -w $@)"
}

###############
### IMPORTS ###
###############
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

##############
### ZOXIDE ###
##############
# https://github.com/ajeetdsouza/zoxide
# Add this to the end of your config file (usually ~/.zshrc):
eval "$(zoxide init zsh)"