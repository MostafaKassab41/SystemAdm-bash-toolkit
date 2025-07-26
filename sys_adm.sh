#!/bin/bash

# Source the module files

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" 
MODULES_DIR="$SCRIPT_DIR/modules"

if [ ! -d "$MODULES_DIR" ]; then
    show_error "Error: Modules directory '$MODULES_DIR' not found." >&2
    exit 1
fi

for module_file in "$MODULES_DIR"/*.sh; do 
    if [ -f "$module_file" ]; then 
        # shellcheck disable=SC1090
        source "$module_file"
    fi
done


#--------------------------------------

# Function to check if running as root
check_root

# Starts an infinite loop to keep the menu active until "Exit" is chosen.
while true; do
    # Display main menu
    choice=$(whiptail --title "Main Menu" --menu "Choose an option" 20 50 10 \
        "1" "Add User" \
        "2" "Delete User" \
        "3" "Modify User" \
        "4" "List Users" \
        "5" "Add Group" \
        "6" "Delete Group" \
        "7" "Modify Group" \
        "8" "list Groups" \
        "9" "About" \
        "10" "Exit" \
        3>&1 1>&2 2>&3
        )


    # Check if user cancelled
    if [ $? -ne 0 ]; then
        break
    fi

    case $choice in
            1) # Create New User
                create_new_user ;;
            2) # Delete User
                delete_user ;;
            3) # Modify User
                modify_user ;;
            4) # List Users
                display_users ;;
            5) # Add Group
                create_group ;;
            6) # Delete Group
                delete_group ;;
            7) # Modify Group
                modify_group ;;
            8) # List Groups
                list_groups ;;
            9) # About
                about ;;
            10) # Exit
                break
                # Exits the loop, ending the script.
                ;;
        esac

done