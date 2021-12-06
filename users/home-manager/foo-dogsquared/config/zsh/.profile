# This is where environmental variables are set. 
# If you're looking for the aliases, keybindings, and prompts, they are in the equivalent `.rc` (i.e., `.zshrc`, `.bashrc`) file. 

# For more information, see the following Unix Exchange thread (https://unix.stackexchange.com/q/71253). 
# Or the Arch Linux Wiki on zsh (https://wiki.archlinux.org/index.php/Zsh#Startup/Shutdown_files). 
# Also check the manual pages for `zshall` (i.e., `man zshall`). 

# My XDG Base Directory spec configuration. 
# Check it out at https://wiki.archlinux.org/index.php/XDG_Base_Directory for more information. 
export XDG_CACHE_HOME=$HOME/.cache
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share

# My custom variables (only applicable at user level)
export PICTURES_DIRECTORY=$HOME/Pictures
export DOCUMENTS_DIRECTORY=$HOME/Documents
export BIN_DIRECTORY=$HOME/bin
export VIDEO_DIRECTORY=$HOME/recordings

# If you come from bash you might have to change your $PATH.
export DENO_INSTALL="$HOME/.deno"
export PATH="$BIN_DIRECTORY:/usr/local/bin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.gem/ruby/2.7.0/bin:$DENO_INSTALL/bin:$PATH"
# export MANPATH="$MANPATH:$HOME/.local/share/man"

# Common environmental variables. 
# Or at least that'll be used by my setup. 
export EDITOR="nvim"
export TERMINAL="alacritty"
export BROWSER="firefox"
export READ="zathura"
export FILE="lf"

# This is a program that `sudo -a` needs for prompting the user and password. 
export SUDO_ASKPASS="$HOME/.local/bin/askpass"
