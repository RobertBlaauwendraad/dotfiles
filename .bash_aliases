# Plate aliases
alias dc='docker compose'
alias dcr='dc run --rm'
alias plateserver='dcr --service-ports app'
alias set_hosts='sudo docker compose run app rake set_hosts'
alias unset_hosts='sudo docker compose run app rake unset_hosts'

# Dotfiles aliases https://www.atlassian.com/git/tutorials/dotfiles
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# Github Copilot aliases
alias copilot='gh copilot'
alias gcs='gh copilot suggest'
alias gce='gh copilot explain'

# En-/disabeling touchpad while typing
alias dit='gsettings set org.gnome.desktop.peripherals.touchpad "disable-while-typing" true'
alias ent='gsettings set org.gnome.desktop.peripherals.touchpad "disable-while-typing" false'
