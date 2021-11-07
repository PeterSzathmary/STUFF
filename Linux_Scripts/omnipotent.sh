#!/bin/bash

. ./colors.sh

function main()
{
    echo "Inside main function in omnipotent.sh"
    . ./menu.sh

    run_checks

    user_options=( "${user_options[@]}" )
    options=( "${options[@]}" )

    # 1. All user's options have to be less than all available options.
    # 2. All user's options have to be positive integers.
    # 3. All user's options have to be in range.
    # OR
    # 4. User's only choice was downloading all.
    if [[ ${#user_options[@]} -lt $((${#options[@]}+1)) && $res1 -eq 0 && $res2 -eq 0 ]] || [[ $res3 -eq 0 ]]
    then
        echo -e "${green}OK${no_color}"
        # Install selected "packages."
        # Loop through the options the user has choosed and print them.
        for i in "${arr[@]}"
        do
            if [[ $i -ne 14  ]]
            then
                echo -e "Installing -> ${green}${options[$((i-1))]}${no_color}"
                sleep 1
                # Call funtction the user has choosed.
                eval ${options[$((i-1))]}
            else
                echo -e "${green}Everything is going to be installed...${no_color}"
                sleep 2
                all_install
            fi
        done

        # TODO:
        # check_installation_status

        echo "All is done!"
        echo "Press ANY key to reboot..."
        read
        sudo reboot +0
    else
        echo -e "${red}NOK${no_color}"
        # Abort the process.
    fi
}

function run_checks()
{
    # Check if all inputs from user are positive integers.
    all_positive_integers_in_array "${user_options[@]}"
    # YES res1 -> 0
    # NO res1 -> 1
    res1=$?

    # Check if all user inputs are in correct range of options.
    is_option_in_range ${user_options[@]}
    # YES res2 -> 0
    # NO res2 -> 1
    res2=$?

    # Check if user wants to install all packages, without choosing any others.
    # So returns 0 only when, the user chose 14.
    only_all ${user_options[@]}
    # YES res3 -> 0
    # NO res3 -> 1
    res3=$?
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
        echo -e "${yellow}GUI is already installed...${no_color}"
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
    else
        echo -e "${yellow}Java is already installed...${no_color}"
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
    else
        echo -e "${yellow}Awesome Vim is already installed...${no_color}"
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
    else
        echo -e "${yellow}NodeJS is already installed...${no_color}"
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
    else
        echo -e "${yellow}GCC is already installed...${no_color}"
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
    else
        echo -e "${yellow}Apache is already installed...${no_color}"
    fi
}

function mariadb_install()
{
    if [ ! -f /mariadb_installed ]
    then
        # Install MariaDB Server.
        #wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
        curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
        sleep 5
        #chmod +x mariadb_repo_setup
        sudo bash mariadb_repo_setup --mariadb-server-version=10.6
        sudo sed -i 's/gpgcheck = 1/gpgcheck = 0/g' /etc/yum.repos.d/mariadb.repo
        sleep 5
        #sudo ./mariadb_repo_setup
        sudo yum install MariaDB-server MariaDB-client MariaDB-backup -y
        sleep 5
        #sudo yum install MariaDB-server -y
        sleep 5
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
    else
        echo -e "${yellow}MariaDB is already installed...${no_color}"
    fi
}

function php_install()
{
    if [ ! -f /php_installed ]
    then
        sudo yum install centos-release-scl.noarch -y
        sudo yum install rh-php72 rh-php72-php rh-php72-php-mysqlnd -y

        sudo ln -s /opt/rh/rh-php72/root/usr/bin/php /usr/bin/php

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

        sudo touch /php_installed
    else
        echo -e "${yellow}PHP is already installed...${no_color}"
    fi

    # if [ -f /apache_installed ] && [ ! -f /php_softlinks_configured ]
    # then
    #     sudo ln -s /opt/rh/httpd24/root/etc/httpd/conf.d/rh-php72-php.conf /etc/httpd/conf.d/
    #     sudo ln -s /opt/rh/httpd24/root/etc/httpd/conf.modules.d/15-rh-php72-php.conf /etc/httpd/conf.modules.d/
    #     sudo ln -s /opt/rh/httpd24/root/etc/httpd/modules/librh-php72-php7.so /etc/httpd/modules/

    #     sudo systemctl restart httpd

    #     sudo touch /php_softlinks_configured
    # else
    #     echo "Soft links were already created for php in /etc/httpd/{conf.d,conf.modules.d,modules}"
    # fi
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
    else
        echo -e "${yellow}Wordpress is already installed...${no_color}"
    fi
}

function all_install()
{
    update_system
    gui_install
    basic_install
    java_install
    awesome_vim
    ohmyzsh_setup
    nodejs_install
    #gcc_install
    miniconda_install
    apache_install
    mariadb_install
    php_install
    wordpress_install
}

main