#!/bin/sh
source /etc/os-release || printf "Could not find /etc/os-release" && exit 1
source ./functions || printf "Could not find functions" && exit 1
sdir=$(pwd)

# Check if user is root
check_user

# Create new user
create_user

# Check distro to install packages
check_distro

# Make .Xauthority file
make_xauth

# Checking if the device has an IBM TrackPoint; if so, moves the file to /etc/X11, if not deletes it
is_thinkpad

# Cloning dotfiles directory
get_dots

# Cloning and installing packages from github repos
get_gitrepos

# Completion text
completion
