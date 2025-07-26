#!/bin/bash

# Import common functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/common.sh"

delete_user() {
    # Get username to delete
    all_users=$(awk -F: '($3 > 1000 && $3 != 65534) {printf "%s%s" , $1 , " | " } ' /etc/passwd)
    username=$(whiptail --inputbox "Current Users:\n$all_users\n\nEnter username to delete:" 16 80 3>&1 1>&2 2>&3)
    
    [ $? -ne 0 ] && { show_error "Operation cancelled."; return; }
    [ -z "$username" ] && { show_error "Username cannot be empty!"; return; }

    # Verify user exists
    if ! id "$username" &>/dev/null; then
        show_error "User '$username' does not exist!"
        return
    fi

    # Show user info before deletion
    user_info=$(getent passwd "$username")
    confirm_msg="About to DELETE user:\n\n$user_info\n\nContinue?"

    if ! whiptail --title "Confirm Deletion" --yesno "$confirm_msg" 14 60; then
        show_error "User deletion cancelled."
        return
    fi

    # Delete user (with home directory)
    if sudo userdel -r "$username" 2>/tmp/userdel_error; then
        show_success "User '$username' deleted successfully!"
    else
        show_error "Failed to delete user:\n$(cat /tmp/userdel_error)"
        rm -f /tmp/userdel_error
    fi
}