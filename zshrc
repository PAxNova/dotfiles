# ZSH configuration file with comments and updates for clarity and maintenance

# Path to Oh-My-Zsh installation
ZSH=$HOME/.oh-my-zsh

# Set the ZSH theme (choose from available themes at the URL below)
# https://github.com/robbyrussell/oh-my-zsh/wiki/themes
ZSH_THEME="robbyrussell"

# Enable useful Oh-My-Zsh plugins for enhanced functionality during Le Wagon bootcamps
plugins=(git gitfast last-working-dir common-aliases zsh-syntax-highlighting history-substring-search)

# (macOS-only) Prevent Homebrew from reporting analytics
# Reference: https://github.com/Homebrew/brew/blob/master/docs/Analytics.md
export HOMEBREW_NO_ANALYTICS=1

# Disable warnings about insecure completion-dependent directories
ZSH_DISABLE_COMPFIX=true

# Source the Oh-My-Zsh script to load its features
source "${ZSH}/oh-my-zsh.sh"

# Unalias conflicting commands to avoid interference with tools
unalias rm # No interactive rm by default (brought by plugins/common-aliases)
unalias lt # We need `lt` for https://github.com/localtunnel/localtunnel

# Load rbenv for managing Ruby versions if installed
# Added for compatibility with Ruby version management
export PATH="${HOME}/.rbenv/bin:${PATH}" # Needed for Linux/WSL
type -a rbenv > /dev/null && eval "$(rbenv init -)"

# Load pyenv for managing Python versions if installed
# Updated to include virtualenv initialization for Python environments
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
type -a pyenv > /dev/null && eval "$(pyenv init -)" && eval "$(pyenv virtualenv-init - 2> /dev/null)" && RPROMPT+='[🐍 $(pyenv version-name)]'

# Load nvm (Node Version Manager) for managing Node.js versions
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Load nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # Load nvm bash_completion

# Automatically switch Node.js versions based on .nvmrc file in the directory
autoload -U add-zsh-hook
load-nvmrc() {
  if nvm -v &> /dev/null; then
    local node_version="$(nvm version)"
    local nvmrc_path="$(nvm_find_nvmrc)"

    if [ -n "$nvmrc_path" ]; then
      local nvmrc_node_version=$(nvm version "$(cat \"${nvmrc_path}\")")

      if [ "$nvmrc_node_version" = "N/A" ]; then
        nvm install
      elif [ "$nvmrc_node_version" != "$node_version" ]; then
        nvm use --silent
      fi
    elif [ "$node_version" != "$(nvm version default)" ]; then
      nvm use default --silent
    fi
  fi
}
type -a nvm > /dev/null && add-zsh-hook chpwd load-nvmrc
type -a nvm > /dev/null && load-nvmrc

# Rails and Node.js binaries are stored locally in projects. Prepend their paths for priority.
export PATH="./bin:./node_modules/.bin:${PATH}:/usr/local/sbin"

# Load custom aliases if the file exists
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

# Set terminal encoding to UTF-8 for consistent behavior
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Set default editors for Ruby and general usage to VSCode
export BUNDLER_EDITOR=code
export EDITOR=code

# Set ipdb as the default Python debugger
# Added for ease of debugging Python applications
export PYTHONBREAKPOINT=ipdb.set_trace

# Set GitHub username for identifying contributions
export GITHUB_USERNAME="PAxNova"

# Add an alias to make `python` point to Python 3 explicitly
alias python=python3

# Load additional environment variables and scripts from .local/bin
# Ensures custom scripts in ~/.local/bin are available globally
. "$HOME/.local/bin/env"
export PATH="$HOME/.local/bin:$PATH"

# Add Python 3.12 to the PATH and prioritize it
# Ensures Python 3.12 is used as the default version for `python3`
export PATH="/opt/homebrew/opt/python@3.12/libexec/bin:$PATH"
