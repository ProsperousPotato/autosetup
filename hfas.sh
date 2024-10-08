#!/bin/sh
source /etc/os-release || { printf "Could not find /etc/os-release"; exit 1; }
source ./functions || { printf "Could not find functions"; exit 1; }
sdir=$(pwd)

# Check if user is root
check_user

# Create new user
create_user

# Check if user is running artix, and adds arch repos if so.
artix_add_arch_repos

# Check distro to install packages
check_distro

# Cloning dotfiles directory
get_dots

# Cloning and installing packages from github repos
get_gitrepos

# Completion text
completion
