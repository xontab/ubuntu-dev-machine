#!/bin/bash

CHOICES=( "$@" )

# shellcheck source=/dev/null
source /etc/os-release

# Uncomment the below line to define a custom Ubuntu version
#UBUNTU_CODENAME=jammy
RIDER_FILENAME=JetBrains.Rider-2023.3-EAP3-233.9802.20.Checked.tar.gz
RIDER_ROOT_FOLDER="JetBrains Rider-233.9802.20"

# --------------------------------------------------------------------------------

COLOR_CYAN="\033[0;96m"
COLOR_YELLOW="\033[0;93m"
COLOR_RESET="\033[0m"

tput reset

echo -e "The following is the configuration that will be used during the installation:

${COLOR_YELLOW}UBUNTU_CODENAME${COLOR_RESET} is ${COLOR_CYAN}$UBUNTU_CODENAME${COLOR_RESET}"


if [[ ${CHOICES[*]} =~ '"6"' ]]; then
  echo -e "${COLOR_YELLOW}RIDER_FILENAME${COLOR_RESET} is ${COLOR_CYAN}$RIDER_FILENAME${COLOR_RESET}
${COLOR_YELLOW}RIDER_ROOT_FOLDER${COLOR_RESET} is ${COLOR_CYAN}$RIDER_ROOT_FOLDER${COLOR_RESET}"
fi

echo -e "
To change press ${COLOR_YELLOW}CTRL+C${COLOR_RESET} to terminate and hard-code variable in script.sh file.

${COLOR_YELLOW}Press any key to continue.${COLOR_RESET}"

read -r

tput reset

# --------------------------------------------------------------------------------

echo Updating System
sudo apt update
sudo apt upgrade -y
sudo snap refresh 

# --------------------------------------------------------------------------------

if [[ ${CHOICES[*]} =~ '"1"' ]]; then
  echo Installing essential tools
  sudo apt install curl git gitg htop btop tilix neovim tldr -y
  tldr -u
fi

# --------------------------------------------------------------------------------

if [[ ${CHOICES[*]} =~ '"2"' ]]; then
  echo Customising zsh
  sudo apt install zsh git curl fzf -y
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  sed -i 's/robbyrussell/powerlevel10k\/powerlevel10k/g' ~/.zshrc
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab

  sed -i 's/^plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf-tab)/g' ~/.zshrc

  sudo chsh -s "$(which zsh)" "$USER"

  # shellcheck disable=SC2016
  echo -e '
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
' >> ~/.zshrc 
  cp ./.p10k.zsh ~/.p10k.zsh
fi

# --------------------------------------------------------------------------------

if [[ ${CHOICES[*]} =~ '"3"' ]]; then
  echo Installing Brew
  sudo apt install git gcc curl -y
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  (echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/"$USER"/.zshrc
  (echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/"$USER"/.bashrc
fi

# --------------------------------------------------------------------------------

if [[ ${CHOICES[*]} =~ '"4"' ]]; then
  echo Installing Docker
  sudo apt install ca-certificates curl gnupg -y
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo rm /etc/apt/keyrings/docker.gpg -f
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $UBUNTU_CODENAME stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
  sudo usermod -aG docker $USER
fi

# --------------------------------------------------------------------------------

if [[ ${CHOICES[*]} =~ '"5"' ]]; then
  echo Installing .NET
  # Get Ubuntu version
  declare repo_version=$(if command -v lsb_release &> /dev/null; then lsb_release -r -s; else grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"'; fi)
  # Download Microsoft signing key and repository
  wget https://packages.microsoft.com/config/ubuntu/$repo_version/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
  # Install Microsoft signing key and repository
  sudo dpkg -i packages-microsoft-prod.deb
  # Clean up
  rm packages-microsoft-prod.deb
  # Update packages
  sudo apt update
  sudo apt-get install dotnet-sdk-8.0 -y
fi

# --------------------------------------------------------------------------------

if [[ ${CHOICES[*]} =~ '"6"' ]]; then
  echo Installing Rider
  wget https://download-cdn.jetbrains.com/rider/$RIDER_FILENAME
  tar -xvzf $RIDER_FILENAME
  mv "./$RIDER_ROOT_FOLDER/" rider
  sudo mv ./rider /usr/lib/
  rm $RIDER_FILENAME

  echo Adding Rider shortcut
  cat << EOF > ~/.local/share/applications/com.jetbrains-rider.desktop
[Desktop Entry]
Version=1.1
Type=Application
Name=JetBrains Rider
Comment=A cross-platform IDE for .NET
Icon=/usr/lib/rider/bin/rider.svg
Exec="/usr/lib/rider/bin/rider.sh" %f
Actions=
Categories=Development;IDE;
StartupNotify=true
StartupWMClass=jetbrains-rider
EOF
  xdg-desktop-menu install ~/.local/share/applications/com.jetbrains-rider.desktop
fi

#--------------------------------------------------------------------------------

if [[ ${CHOICES[*]} =~ '"7"' ]]; then
  echo Installing Visual Studio Code
  sudo apt install curl -y
  curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
  sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft-archive-keyring.gpg
  sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
  sudo apt update
  sudo apt-get install code -y
  rm microsoft.gpg
fi

#--------------------------------------------------------------------------------

if [[ ${CHOICES[*]} =~ '"8"' ]]; then
  echo  Installing Google Chrome
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo apt install ./google-chrome-stable_current_amd64.deb -y
  rm google-chrome-stable_current_amd64.deb
  sudo update-alternatives --set x-www-browser /usr/bin/google-chrome-stable
fi

#--------------------------------------------------------------------------------

if [[ ${CHOICES[*]} =~ '"9"' ]]; then
  echo Adding Customisations
  cp -r ./fonts/ ~/.local/share/

  # Bash
  echo 'alias ..="cd .."' >> ~/.bashrc
  echo 'alias ...="cd ../.."' >> ~/.bashrc
  echo 'alias ....="cd ../../.."' >> ~/.bashrc
  echo 'alias .....="cd ../../../.."' >> ~/.bashrc
  echo 'alias g="git"' >> ~/.bashrc
  echo 'alias ll="ls -hal --color=auto"' >> ~/.bashrc

  # ZSH
  echo 'alias ..="cd .."' >> ~/.zshrc
  echo 'alias ...="cd ../.."' >> ~/.zshrc
  echo 'alias ....="cd ../../.."' >> ~/.zshrc
  echo 'alias .....="cd ../../../.."' >> ~/.zshrc
  echo 'alias g="git"' >> ~/.zshrc
  echo 'alias ll="ls -hal --color=auto"' >> ~/.zshrc

  git config --global alias.co checkout
  git config --global alias.ct commit
  git config --global alias.st status
  git config --global alias.br branch
  git config --global alias.p push

  # Cinnamon
  gsettings set org.cinnamon.desktop.keybindings custom-list "['custom0']"
  gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom0/ binding "['<Primary>F10']"
  gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom0/ command "'tilix --quake --full-screen'"
  gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom0/ name "'Tilix'"

  # GNOME
  gsettings set org.gnome.desktop.wm.preferences auto-raise 'true'
  gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "'<Primary>F12'"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "'env GDK_BACKEND=x11 tilix --quake --full-screen'"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "'Tilix'"

  gsettings set org.gnome.desktop.interface font-name 'SF UI Display 11'
  gsettings set org.gnome.desktop.interface document-font-name 'SF UI Display 11'
  gsettings set org.gnome.desktop.wm.preferences titlebar-font 'SF UI Display 11'
  gsettings set org.gnome.desktop.interface monospace-font-name 'Hack Nerd Font 16'
  gsettings set org.gnome.gedit.preferences.editor editor-font 'Hack Nerd Font 13'

  sudo update-alternatives --set x-terminal-emulator /usr/bin/tilix.wrapper
fi

#--------------------------------------------------------------------------------

if [[ ${CHOICES[*]} =~ '"10"' ]]; then
  echo Configure Fingerprint Authentication
  # Enable the following commands if desktop environment does not provide a way to configure fingerprints
  #sudo apt install libpam-fprintd -y
  #sudo fprintd-enroll -f right-index-finger
  sudo pam-auth-update --enable fprintd
fi

#--------------------------------------------------------------------------------

echo Cleanup
sudo apt autoremove -y
