# History
HISTFILE=~/.zsh_history
SAVEHIST=9999
HISTSIZE=9999

setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt NO_NOMATCH                # Accept ^ character
setopt HIST_FIND_NO_DUPS         # Don't show duplicate history entires
setopt HIST_REDUCE_BLANKS        # Remove unnecessary blanks from history
setopt SHARE_HISTORY             # share history between instances
setopt NO_HUP                    # Don't hang up background jobs
setopt CORRECT                   # autocorrect command spelling

# Language
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8