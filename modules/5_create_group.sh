#!/bin/bash

# Import common functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/common.sh"


create_group() {
    groupname=$(whiptail --inputbox "Enter new group name:" 8 40 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && { show_error "Operation cancelled."; return; }
    [ -z "$groupname" ] && { show_error "Group name cannot be empty!"; return; }

    if getent group "$groupname" &>/dev/null; then
        show_error "Group '$groupname' already exists!"
        return
    fi

    gid=$(whiptail --inputbox "Enter Group ID (leave empty for automatic):" 8 40 3>&1 1>&2 2>&3)
    local groupadd_cmd="groupadd"
    [ -n "$gid" ] && groupadd_cmd+=" -g $gid"
    groupadd_cmd+=" $groupname"

    if sudo $groupadd_cmd 2>/tmp/groupadd_error; then
        show_success "Group '$groupname' created successfully!"
    else
        show_error "Failed to create group:\n$(cat /tmp/groupadd_error)"
        rm -f /tmp/groupadd_error
    fi
}