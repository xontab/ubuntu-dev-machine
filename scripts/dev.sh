#!/bin/bash

# shellcheck source=/dev/null
source /etc/os-release

# Uncomment the below line to define a custom Ubuntu version
#UBUNTU_CODENAME=jammy
RIDER_FILENAME=JetBrains.Rider-2023.3-EAP3-233.9802.20.Checked.tar.gz
RIDER_ROOT_FOLDER="JetBrains Rider-233.9802.20"

DOTNET_FILENAME=dotnet-sdk-8.0.100-rc.2.23502.2-linux-x64.tar.gz
DOTNET_DOWNLOAD_LINK=https://download.visualstudio.microsoft.com/download/pr/9144f37e-b370-41ee-a86f-2d2a69251652/bc1d544112ec134184a5aec7f7a1eaf9/$DOTNET_FILENAME

# --------------------------------------------------------------------------------

COLOR_CYAN="\033[0;96m"
COLOR_YELLOW="\033[0;93m"
COLOR_RESET="\033[0m"

tput reset

echo -e "---------------------------------------------------------------------------
| Ubuntu Development Setup Installer v1.0.0                               |
---------------------------------------------------------------------------

${COLOR_YELLOW}UBUNTU_CODENAME${COLOR_RESET} is ${COLOR_CYAN}$UBUNTU_CODENAME${COLOR_RESET}
${COLOR_YELLOW}RIDER_FILENAME${COLOR_RESET} is ${COLOR_CYAN}$RIDER_FILENAME${COLOR_RESET}
${COLOR_YELLOW}RIDER_ROOT_FOLDER${COLOR_RESET} is ${COLOR_CYAN}$RIDER_ROOT_FOLDER${COLOR_RESET}
${COLOR_YELLOW}DOTNET_FILENAME${COLOR_RESET} is ${COLOR_CYAN}$DOTNET_FILENAME${COLOR_RESET}
${COLOR_YELLOW}DOTNET_DOWNLOAD_LINK${COLOR_RESET} is ${COLOR_CYAN}$DOTNET_DOWNLOAD_LINK${COLOR_RESET}

To change press ${COLOR_YELLOW}CTRL+C${COLOR_RESET} to terminate and hard-code variable in script file.
Script will continue to run in 15 seconds."

sleep 15

tput reset

# --------------------------------------------------------------------------------

echo Updating System
sudo apt update
sudo apt upgrade -y

# --------------------------------------------------------------------------------

echo Installing essential tools
sudo apt install git htop zsh ca-certificates curl gnupg gitg tilix fzf -y

# --------------------------------------------------------------------------------

echo Customising zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
sed -i 's/robbyrussell/powerlevel10k\/powerlevel10k/g' ~/.zshrc
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab

sed -i 's/^plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf-tab)/g' ~/.zshrc

sudo chsh -s "$(which zsh)" "$USER"

# --------------------------------------------------------------------------------

echo Installing Brew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/"$USER"/.zshrc
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/"$USER"/.bashrc

# --------------------------------------------------------------------------------

echo  Installing Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb -y
rm google-chrome-stable_current_amd64.deb
sudo update-alternatives --set x-www-browser /usr/bin/google-chrome-stable

# --------------------------------------------------------------------------------

echo Installing .NET
sudo apt-get install dotnet-sdk-7.0 -y

# Temporary installation for .NET 8
wget $DOTNET_DOWNLOAD_LINK
sudo tar -xvzf $DOTNET_FILENAME --directory /usr/lib/dotnet
rm $DOTNET_FILENAME

#--------------------------------------------------------------------------------

echo Installing Docker
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

#--------------------------------------------------------------------------------

echo Installing Rider
wget https://download-cdn.jetbrains.com/rider/$RIDER_FILENAME
tar -xvzf $RIDER_FILENAME
mv "./$RIDER_ROOT_FOLDER/" rider
sudo mv ./rider /usr/lib/
rm $RIDER_FILENAME

echo Adding Rider shortcut
cat << EOF > ~/.local/share/applications/com.jetbrains-rider.desktop
[Desktop Entry]
Name=Rider
Exec=/usr/lib/rider/bin/rider.sh
Comment=JetBrains Rider IDE.
Terminal=false
PrefersNonDefaultGPU=false
Icon=/usr/lib/rider/bin/rider.png
Type=Application
Categories=Development;
EOF
xdg-desktop-menu install ~/.local/share/applications/com.jetbrains-rider.desktop

#--------------------------------------------------------------------------------

echo Installing Visual Studio Code
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft-archive-keyring.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt-get install code -y
rm microsoft.gpg

#--------------------------------------------------------------------------------

echo Adding Customisations
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
gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom0/ binding "['<Primary>F12']"
gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom0/ command "'tilix --quake --full-screen'"
gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom0/ name "'Tilix'"

# GNOME
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "'<Primary>F12'"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "'env GDK_BACKEND=x11 tilix --quake --full-screen'"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "'Tilix'"

sudo update-alternatives --set x-terminal-emulator /usr/bin/tilix.wrapper

#--------------------------------------------------------------------------------

echo Configure authentication

#Enable the following commands if desktop environment does not provide a way to configure fingerprints
#sudo apt install libpam-fprintd -y
#sudo fprintd-enroll -f right-index-finger
sudo pam-auth-update

#--------------------------------------------------------------------------------

echo Installation completed. Restarting in 10 seconds. Press CTRL+C to terminate.
sleep 10
sudo reboot
