#!/bin/bash

# Common variables and functions


# Function to display error messages
show_error() {
    whiptail --title "Error" --msgbox "$1" 8 50
}

# Function to display success messages
show_success() {
    whiptail --title "Success" --msgbox "$1" 8 50
}

# Function to check if running as root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        show_error "This operation requires root privileges!"
        exit
    fi
}