#!/bin/sh
source /etc/os-release
sdir=$(pwd)
distro_like=$ID_LIKE

# Checking if user is root and if not, tells them to use the 'su' command to become root
if [ $UID != 0 ];then 
    echo "You are not root, run the comand 'su' before attempting to run this script"
    exit 1
fi

# Prompt for the username
read -p "Enter the username: " username

# Check if the username was provided
if [ -z "$username" ]; then
    echo "Username cannot be empty. Exiting."
    exit 1
fi

# Check if the user already exists
if id "$username" &>/dev/null; then
    echo "$username already exists. Exiting."
    exit 1
fi

# Prompt for the password
read -sp "Enter the password: " password
echo

# If no password is provided, then generate a random one
if [ -z "$password" ]; then
    password=$(openssl rand -base64 12)
    echo "No password provided. Generated random password: $password"
fi

# Prompt for additional groups (optional)
read -p "Enter any additional groups (not recommended, just go with the defaults dude): " groups

# Create the user and their home directory
useradd -m -s /bin/bash "$username"

# Set the user's password
echo "$username:$password" | chpasswd

# Add user to additional groups if specified
if [ -n "$groups" ]; then
    usermod -aG $groups "$username"
else
    usermod -aG root tty wheel audio video input storage "$username"
fi

# Print out user information
echo "$username created successfully."
echo "Username: $username"
echo "Hopefully you remember your password"
if [ -n "$groups" ]; then
    echo "Groups: $groups" && sleep 10
else echo "Groups: root tty wheel audio video input storage" && sleep 10
fi

# Uses the ID varaible in /etc/os-release for trying to detect system package manager
case $ID in
    gentoo)
        packList="gentoo/$ID.txt"
        echo "Distro: Gentoo"
        echo "Package List: $packList"
        echo "Package Manager: emerge" && sleep 2
        echo "If you want to change the make.conf do it now to the one in the gentoo directory because the other one is going to be overwritten"
        echo "Pretending emerge, you have 1 minute to look over the packages before it will begin" && sleep 2
        mv -f gentoo/make.conf /etc/portage/ ; mv -f gentoo/steam /etc/portage/package.use 
        xargs emerge -pv < $packList && sleep 60 ; echo "Time's up, installing packages for your system from $packList with emerge, this will begin in 5 seconds" && sleep 5
        xargs emerge -v < $packList
        ;;
    debian)
        packList="debian/$ID.txt"
        echo "Distro: Debian"
        echo "Package List: $packList"
        echo "Package Manager: apt-get" && sleep 2
        echo "Packages will be installed and files will be placed in directories that may overwrite original configurations"
        echo "Installing packages for your system from $packList with apt-get, this will begin in 5 seconds" && sleep 5 ; xargs apt-get -y install < $packList
        ;;
    fedora|rhel)
        packList="fedora/$ID.txt"
        echo "Distro: Fedora"
        echo "Package List: $packList"
        echo "Package Manager: dnf" && sleep 2
        echo "Packages will be installed and files will be placed in directories that may overwrite original configurations"
        echo "Installing packages for your system from $packList with dnf, this will begin in 5 seconds" && sleep 5 ; xargs dnf -y install < $packList
        ;;
    arch|artix)
        packList="arch/$ID.txt"
        echo "Distro: Arch"
        echo "Package List: $packList"
        echo "Package Manager: pacman" && sleep 2
        echo "Packages will be installed and files will be placed in directories that may overwrite original configurations"
        echo "Installing packages for your system from $packList with pacman, this will begin in 5 seconds" && sleep 5 ; xargs pacman -Sy --needed --noconfirm < $packList
        ;;
    opensuse|suse)
        packList="suse/$ID.txt"
        echo "Distro: SUSE"
        echo "Package List: $packList"
        echo "Package Manager: zypper" && sleep 2
        echo "Packages will be installed and files will be placed in directories that may overwrite original configurations"
        echo "Installing packages for your system from $packList with zypper, this will begin in 5 seconds" && sleep 5 ; xargs zypper install -l -y < $packList
        ;;
esac

# Uses ID_LIKE variable in os_release to try to determine package manager to use.
case $ID_LIKE in 
    gentoo)
        packList="gentoo/$ID.txt"
        echo "Distro: $distro_like"
        echo "Package List: $packList"
        echo "Package Manager: emerge" && sleep 2
        echo "If you want to change the make.conf do it now to the one in the gentoo directory"
        echo "Pretending emerge, you have 1 minute to look over the packages before it will begin" 
        xargs emerge -pv < $packList && sleep 60 ; echo "Time's up, installing packages for your system from $packList with emerge, this will begin in 5 seconds" && sleep 5
        mv -f gentoo/make.conf /etc/portage/ ; mv -f gentoo/steam /etc/portage/package.use ; xargs emerge -v < $packList
        ;;
    debian|ubuntu)
        packList="debian/$ID.txt"
        echo "Distro: $distro_like"
        echo "Package List: $packList"
        echo "Package Manager: apt-get" && sleep 2
        echo "Packages will be installed and files will be placed in directories that may overwrite original configurations"
        echo "Installing packages for your system from $packList with apt-get, this will begin in 5 seconds" && sleep 5 ; xargs apt-get -y install < $packList
        ;;
    fedora|rhel)
        packList="fedora/$ID.txt"
        echo "Distro: $distro_like"
        echo "Package List: $packList"
        echo "Package Manager: dnf" && sleep 2
        echo "Packages will be installed and files will be placed in directories that may overwrite original configurations"
        echo "Installing packages for your system from $packList with dnf, this will begin in 5 seconds" && sleep 5 ; xargs dnf -y install < $packList
        ;;
    arch)
        packList="arch/$ID.txt"
        echo "Distro: $distro_like"
        echo "Package List: $packList"
        echo "Package Manager: pacman" && sleep 2
        echo "Packages will be installed and files will be placed in directories that may overwrite original configurations"
        echo "Installing packages for your system from $packList with pacman, this will begin in 5 seconds" && sleep 5 ; xargs pacman -Sy --needed --noconfirm < $packList
        ;;
    opensuse|suse)
        packList="suse/$ID.txt"
        echo "Distro: $distro_like"
        echo "Package List: $packList"
        echo "Package Manager: zypper" && sleep 2
        echo "Packages will be installed and files will be placed in directories that may overwrite original configurations"
        echo "Installing packages for your system from $packList with zypper, this will begin in 5 seconds" && sleep 5 ; xargs zypper install -l -y < $packList
        ;;
esac

# Make .Xauthority file
XAUTH_FILE="/home/$username/.Xauthority"

# Remove the existing .Xauthority file if it exists
if [ -f "$XAUTH_FILE" ]; then
    echo "Removing existing .Xauthority file..."
    rm "$XAUTH_FILE"
fi

# Generate a new Xauthority file
echo "Creating a new .Xauthority file..."
touch "$XAUTH_FILE"

# Create a new X cookie and add it to the .Xauthority file
# The -b option is to force a new cookie to be created
xauth add ${DISPLAY} . $(xauth -b list ${DISPLAY} | awk '{print $3}')

# Verify that the .Xauthority file was created and contains entries
if [ -s "$XAUTH_FILE" ]; then
    echo ".Xauthority file created and updated successfully."
else
    echo "Failed to create the .Xauthority file."
fi
# Making necessary directories
echo "Making necessary directories if you dont already have them" && sleep 2
mkdir /etc/X11/xorg.conf.d 2> /dev/null || echo "/etc/X11/xorg.conf.d directory already exists" && sleep 1

# Cloning dotfiles directory
echo "Cloning dot file directory" && sleep 1
git clone --quiet https://github.com/ProsperousPotato/dotfiles
cd dotfiles
# Checking if the device has an IBM TrackPoint; if so, moves the file to /etc/X11, if not deletes it
if [ `xinput --list | grep TPPS/2 | awk {print'$3''$4''$5'}` = TPPS/2IBMTrackPoint ]; then
    echo "You probably have a Thinkpad (or at least a trackpoint), moving trackpoint config file to xorg config directory" && sleep 2
    mv -f xorg.conf.d/25-thinkpad.conf /etc/X11/xorg.conf.d/
else
    rm xorg.conf.d/25-thinkpad.conf
fi

# Checking if an intel.conf file was created when installing xorg-server
INTEL_CONF="/etc/X11/xorg.conf.d/*intel.conf"

if [ -f "$INTEL_CONF" ]; then
    rm xorg.conf.d/20-intel.conf
else
    mv xorg.conf.d/20-intel.conf /etc/X11/xorg.conf.d/
fi
# Moving dotfiles around
echo "Moving dotfiles to dotfile directories" && sleep 2
mv -f xorg.conf.d/* /etc/X11/xorg.conf.d/

mv -f Xresources /home/$username/.Xresources
mv -f bash_profile /home/$username/.bash_profile
mv -f bashrc /home/$username/.bashrc
mv -f gtkrc-2.0 /home/$username/.gtkrc-2.0
mv -f inputrc /home/$username/.inputrc
mv -f xinitrc /home/$username/.xinitrc
chmod +x local/bin/*
chmod -x local/bin/bookmarksfile
chmod +x config/lf/cleaner
chmod +x config/lf/scope
mv -f config /home/$username/.config ; mv -f local /home/$username/.local
cd .. && rm -rf dotfiles

xrdb -merge /home/$username/.Xresources

# Cloning and installing packages from github repos
echo "cloning git repos, this will take longer depending on your internet speed" && sleep 2
cd /home/$username/.local/src/
git clone --quiet https://github.com/ProsperousPotato/dwm && cd dwm && make clean install && cd ..

git clone --quiet https://github.com/ProsperousPotato/dmenu && cd dmenu && make clean install && cd ..

git clone --quiet https://github.com/ProsperousPotato/st && cd st && make clean install && cd ..

git clone --quiet https://github.com/ProsperousPotato/nsxiv && cd nsxiv && make clean install && cd ..

git clone --quiet https://github.com/ProsperousPotato/slstatus && cd slstatus && make clean install && cd ..

git clone --quiet https://github.com/ProsperousPotato/slock && cd slock && cp -f config.def.h config.h && make clean install

cd $sdir 

# Completion text
chown -R $username /home/$username/
echo "autosetup script completed, type 'man dwm' for instructions on keyboard shortcuts, then log in to your use and it should automagically start a dwm session"
