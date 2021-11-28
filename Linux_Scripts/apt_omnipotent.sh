#!/bin/bash

# . ./colors.sh

function install_configure_needrestart()
{
	sudo apt-get install needrestart -y
	sudo sed -i "s/#$nrconf{restart} = 'i';/$nrconf{restart} = 'a';/g" /etc/needrestart/needrestart.conf
	#\x27 -> single quote '
	#sudo sed -ie 's/#$nrconf{restart} = \x27i\x27;/$nrconf{restart} = \x27a\x27;/g' /etc/needrestart/needrestart.conf
	sudo sed -i 's/#$nrconf{restart} = \x27i\x27;/$nrconf{restart} = \x27a\x27;/g' /etc/needrestart/needrestart.conf
}

function update_system()
{
        #sudo apt-get install needrestart -y
        #sudo sed -i "s/$nrconf{restart} = 'i';/$nrconf{restart} = 'a';/g" /etc/needrestart/needrestart.conf
        sudo apt-get update -y && sudo apt-get dist-upgrade -y
        # Uninstall packages that were installed automatically and are no longer required.
        sudo apt autoremove -y
}

function basic_install()
{
        sudo apt-get install git zsh tree wget fortune-mod cowsay most -y
}

function awesome_vim()
{
    if [ ! -f /awesome_vim_installed ]
    then
        # Awesome VIM
        eval "git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime"
        sh ~/.vim_runtime/install_awesome_vimrc.sh

        for homedir in /home/*
        do
            # Get username from string /home/<username>
            # We want to work with $homedir string, so send it as input to sed.
            # example: /home/testuser -> testuser
            user=$(sed 's/\/home\///' <<< $homedir)

            # Copy .vim_runtime and .vimrc to all users and to /etc/skel.
            for destination in "$homedir/" "/etc/skel/"
            do
                sudo rsync -a ~/.vim_runtime "$destination"
                sudo rsync ~/.vimrc "$destination"
            done

            # Change owner and group for both .vim_runtime recursively and .vimrc for current $user.
            sudo chown -R $user:$user $homedir/.vim_runtime $homedir/.vimrc
        done

        sudo touch /awesome_vim_installed
    else
        echo -e "${yellow}Awesome Vim is already installed...${no_color}"
	:
    fi
}

function nodejs_install()
{
    if [ ! -f /nodejs_installed ]
    then
        # Install latest Node.js v 17.x
        curl -fsSL https://deb.nodesource.com/setup_17.x | sudo -E bash -
        sudo apt-get install -y nodejs

        sudo touch /nodejs_installed
    else
        echo -e "${yellow}NodeJS is already installed...${no_color}"
	:
    fi
}

function java_install()
{
    if [ ! -f /java_installed ]
    then
        # Install latest Java for current user.
	# TODO: for all users
        wget https://download.java.net/java/GA/jdk17.0.1/2a2082e5a09d4267845be086888add4f/12/GPL/openjdk-17.0.1_linux-x64_bin.tar.gz
	tar xvf openjdk-17.0.1_linux-x64_bin.tar.gz
        # Set java version to latest we have just installed.
        # sudo update-alternatives --set java java-latest-openjdk.x86_64
        # Set javac version to latest we have just installed.
        # sudo update-alternatives --set javac java-latest-openjdk.x86_64

	# export PATH=/home/${current_user}/jdk-17.0.1/bin:$PATH

        sudo touch /java_installed
    else
        echo -e "${yellow}Java is already installed...${no_color}"
	:
    fi
}

function ohmyzsh_setup()
{
    if [ ! -f /ohmyzsh_installed ]
    then
        # Install Powerline fonts
        git clone https://github.com/powerline/fonts.git --depth=1
        cd fonts && ./install.sh && cd .. && rm -rf fonts
        # ???BELOW LINES MAYBE NOT NECESSARY???
        #mkdir /usr/share/fonts
        #cp /root/.local/share/fonts/* /usr/share/fonts

        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

        # These two themes are buggy, remove them.
        rm -f ~/.oh-my-zsh/themes/{pygmalion.zsh-theme,pygmalion-virtualenv.zsh-theme}

        # Make all users use ohmyzsh who are already created.
        for homedir in /home/*
        do
            # Get username from string /home/<username>
            # We want to work with $homedir string, so send it as input to sed.
            # example: /home/testuser -> testuser
            user=$(sed 's/\/home\///' <<< $homedir)
            sudo rsync -a ~/.oh-my-zsh $homedir
            sudo rsync ~/.zshrc $homedir

            # Change owner and group for both .oh-my-zsh recursively and .zshrc for current $user.
            sudo chown -R $user:$user $homedir/.oh-my-zsh $homedir/.zshrc

            # Change export ZSH in .zshrc for current $user.
            #sed -i 's/export ZSH=\"\/home\/adam\/.oh-my-zsh\"/export ZSH=\"\/home\/$user\/.oh-my-zsh\"' $homedir/.zshrc
            sudo sed -i 's/export ZSH="\/root\/.oh-my-zsh"/export ZSH="\/home\/'$user'\/.oh-my-zsh"/' $homedir/.zshrc
            sudo sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="random"/' $homedir/.zshrc

            sudo chsh -s /bin/zsh $user
        done

        # Make sure that all new users will use zsh from now on instead of bash.
        sudo sed -i 's/\/bin\/bash/\/bin\/zsh/' /etc/default/useradd

        # Set PAGER for current user. (should be root)
        echo "export PAGER='most'" >> ~/.zshrc

        # Make sure that all new users will use ohmyzsh.
        sudo rsync -a ~/.oh-my-zsh /etc/skel
        sudo rsync ~/.zshrc /etc/skel

        # Edit .zshrc in skel: export ZSH=/home/$USER/.oh-my-zsh
        sudo sed -i 's/export ZSH="\/root\/.oh-my-zsh"/export ZSH="\/home\/$USER\/.oh-my-zsh"/' /etc/skel/.zshrc

        # Change ZSH_THEME in /etc/skel
        sudo sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="random"/' /etc/skel/.zshrc

        # Change root ZSH_THEME to agnoster.
        sudo sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' ~/.zshrc

        echo "alias vi='vim'" > ~/.oh-my-zsh/custom/my_aliases.zsh

        # Change shell for user running the script. (should be root)
        sudo chsh -s /bin/zsh $USER

        # Create flag file that we have configured oh-my-zsh in our system.
        sudo touch /ohmyzsh_installed
    else
        echo -e "${yellow}OhMyZsh is already installed...${no_color}"
	:
    fi
}

function miniconda_install()
{
    if [ ! -f /miniconda_installed ]
    then
        # Install Miniconda for Python development.
        wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
        sh Miniconda3-latest-Linux-x86_64.sh -b
        cd ~/miniconda3/bin && ./conda update conda -y && ./conda update --all -y && ./conda init zsh
        
        sudo touch /miniconda_installed
    else
        echo -e "${yellow}Miniconda is already installed...${no_color}"
	:
    fi
}

install_configure_needrestart
update_system
basic_install
awesome_vim
nodejs_install
java_install
ohmyzsh_setup
miniconda_install

echo "All is done!"
echo "Press ANY key to reboot..."
read
sudo reboot +0
