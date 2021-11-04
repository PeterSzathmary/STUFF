#!/bin/bash

. ./colors.sh

function main()
{
    update_system
    gui_install
    basic_install
    java_install
    awesome_vim
    ohmyzsh_setup
    nodejs_install
    # gcc_install
    miniconda_install
    apache_install
    mariadb_install
    php_install
    wordpress_install

    # TODO:
    # check_installation_status

    echo "Press ANY key to reboot..."
    read
    sudo reboot +0
}

function update_system()
{
    sudo yum clean all -y
    # Update the system.
    sudo yum update -y
}

function gui_install()
{
    if [ ! -f /gui_installed ]
    then
        echo "GUI is going to be installed..."
        sleep 5
        # Install GUI Gnome.
        sudo yum groups install "GNOME Desktop" -y
        # Tell the X Window System that GNOME is the default GUI.
        sudo echo "exec gnome-session" >> ~/.xinitrc
        # Start using GUI.
        # sudo startx
        # Make sure that GUI start automatically everytime.
        sudo systemctl set-default graphical.target

        # Create flag that GUI is installed.
        sudo touch /gui_installed

        echo "GUI has been installed successfully!"
    else
        echo "GUI is already installed!"
    fi
}

function basic_install()
{
    # Install some packages.
	sudo yum install git epel-release zsh tree xterm wget vim-enhanced -y
	sudo yum install fortune-mod cowsay most -y
}

function java_install()
{
    if [ ! -f /java_installed ]
    then
        # Install latest Java.
        sudo yum install java-latest-openjdk-devel -y
        # Set java version to latest we have just installed.
        sudo update-alternatives --set java java-latest-openjdk.x86_64
        # Set javac version to latest we have just installed.
        sudo update-alternatives --set javac java-latest-openjdk.x86_64

        sudo touch /java_installed
    fi
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
    fi
}

function nodejs_install()
{
    if [ ! -f /nodejs_installed ]
    then
        # Install latest Node.js v 17.x
        curl -fsSL https://rpm.nodesource.com/setup_17.x | sudo bash -
        sudo yum install -y nodejs

        sudo touch /nodejs_installed
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
    fi
}

function gcc_install()
{
    if [ ! -f /gcc_installed ]
    then
        # Save to variable which GCC we want to install.
        GCC_VERSION=11.2.0
        sudo yum -y install bzip2 gcc gcc-c++ gmp-devel mpfr-devel libmpc-devel make -y
        gcc --version
        # echo "Press enter to continue..."
        # read
        wget http://gnu.mirror.constant.com/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz
        tar zxf gcc-$GCC_VERSION.tar.gz
        mkdir gcc-build
        cd gcc-build
        ../gcc-$GCC_VERSION/configure --enable-languages=c,c++ --disable-multilib
        make -j$(nproc)
        sudo make install
        gcc --version
        # echo "Press enter to continue..."
        # read
        cd ..
        rm -rf gcc-build

        sudo touch /gcc_installed
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
    fi
}

function apache_install()
{
    if [ ! -f /apache_installed ]
    then
        # Install Apache HTTP Server.
        sudo yum install httpd -y
        sudo firewall-cmd --permanent --add-service=http --add-service=https -q
        sudo firewall-cmd --reload
        # Enable web server so it starts always after boot.
        sudo systemctl enable httpd.service
        # Start the service.
        sudo systemctl start http.service

        sudo touch /apache_installed
    fi
}

function mariadb_install()
{
    if [ ! -f /mariadb_installed ]
    then
        # Install MariaDB Server.
        wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
        chmod +x mariadb_repo_setup
        sudo ./mariadb_repo_setup
        sudo yum install MariaDB-server -y
        sudo systemctl enable mariadb.service
        sudo systemctl start mariadb.service
        sudo rm ./mariadb_repo_setup

        echo -e -n "${light_cyan}Enter a password for a MariaDB root:${no_color} "
        read -s root_password
        echo

        sleep .5
        sudo mariadb -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$root_password');"

        # Drop all the anonymous users.
        sudo mariadb -u "root" -p"$root_password" -e "DROP USER IF EXISTS ''@'localhost';"

        # Drop off the demo database.
        sudo mariadb -u "root" -p"$root_password" -e "DROP DATABASE IF EXISTS test;"

        # Make our changes take effect.
        sudo mariadb -u "root" -p"$root_password" -e "FLUSH PRIVILEGES;"

        ###############################################
        #                                             #
        #        Prepare MariaDB for Wordpress        #
        #                                             #
        ###############################################

        echo -e -n "${light_cyan}Enter a password for a MariaDB wordpress_admin:${no_color} "
        read -s wordpress_admin_password
        echo

        sudo mariadb -u "root" -p"$root_password" -e "CREATE DATABASE IF NOT EXISTS wordpress_db;"
        sudo mariadb -u "root" -p"$root_password" -e "CREATE USER IF NOT EXISTS wordpress_admin@'localhost' IDENTIFIED BY '$wordpress_admin_password';"
        sudo mariadb -u "root" -p"$root_password" -e "GRANT ALL PRIVILEGES ON wordpress_db.* TO wordpress_admin@'localhost' IDENTIFIED BY '$wordpress_admin_password';"
        sudo mariadb -u "root" -p"$root_password" -e "FLUSH PRIVILEGES;"

        sudo touch /mariadb_installed
    fi
}

function php_install()
{
    if [ ! -f /php_installed ]
    then
        sudo yum install centos-release-scl.noarch -y
        sudo yum install rh-php72 rh-php72-php rh-php72-php-mysqlnd -y

        sudo ln -s /opt/rh/rh-php72/root/usr/bin/php /usr/bin/php

        sudo touch /php_installed
    fi

    if [ -f /apache_installed ] && [ ! -f /php_softlinks_configured ]
    then
        sudo ln -s /opt/rh/httpd24/root/etc/httpd/conf.d/rh-php72-php.conf /etc/httpd/conf.d/
        sudo ln -s /opt/rh/httpd24/root/etc/httpd/conf.modules.d/15-rh-php72-php.conf /etc/httpd/conf.modules.d/
        sudo ln -s /opt/rh/httpd24/root/etc/httpd/modules/librh-php72-php7.so /etc/httpd/modules/

        sudo systemctl restart httpd

        sudo touch /php_softlinks_configured
    else
        echo "Soft links were already created for php in /etc/httpd/{conf.d,conf.modules.d,modules}"
    fi
}

function wordpress_install()
{
    if [ ! -f /wordpress_installed ] && [ -f /apache_installed ] && [ -f /mariadb_installed ] && [ -f /php_installed ]
    then
        cd ~
        wget http://wordpress.org/latest.tar.gz

        tar -xzvf latest.tar.gz

        sudo rsync -avP ~/wordpress/ /var/www/html/
        sudo mkdir /var/www/html/wp-content/uploads
        sudo chown -R apache:apache /var/www/html/*

        cd /var/www/html
        cp wp-config-sample.php wp-config.php

        echo -e -n "${light_cyan}Password for wordpress_admin in MariaDB:${no_color} "
        read -s wordpress_admin_password
        echo

        sudo sed -i 's/database_name_here/wordpress_db/g' /var/www/html/wp-config.php
        sudo sed -i 's/username_here/wordpress_admin/g' /var/www/html/wp-config.php
        sudo sed -i 's/password_here/'$wordpress_admin_password'/g' /var/www/html/wp-config.php

        sudo touch /wordpress_installed

        if [ -f /gui_installed ]
        then
            #firefox http://$(hostname)
            :
        fi
    fi
}

main