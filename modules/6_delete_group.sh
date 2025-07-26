#!/bin/bash

# Import common functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/common.sh"

# Delete existing group
delete_group() {
    all_groups=$(awk -F: '($3 > 1000 && $3 != 65534) || $3 == 10  {printf "%s%s" , $1 , " | " } ' /etc/group)
    groupname=$(whiptail --inputbox "Enter group name to delete:\n\nAvailable groups: $all_groups" 16 80 3>&1 1>&2 2>&3)

    # Check if user press cancel OR no input 
    [ $? -ne 0 ] && { show_error "Operation cancelled."; return; }
    [ -z "$groupname" ] && { show_error "Group name cannot be empty!"; return; }

    # Check if group is exist 
    if ! getent group "$groupname" &>/dev/null; then
        show_error "Group '$groupname' does not exist!"
        return
    fi

    # Extract the members of the group
    members=$(getent group "$groupname" | cut -d: -f4)
    if [ -n "$members" ]; then
        if ! whiptail --yesno "Group '$groupname' has members: $members\n\nDelete anyway?" 12 60; then
            show_error "Group deletion cancelled."
            return
        fi
    fi

    # complete the delete 
    if sudo groupdel "$groupname" 2>/tmp/groupdel_error; then
        show_success "Group '$groupname' deleted successfully!"
    else
        show_error "Failed to delete group:\n$(cat /tmp/groupdel_error)"
        rm -f /tmp/groupdel_error
    fi
}