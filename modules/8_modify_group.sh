#!/bin/bash

# Import common functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/common.sh"

# Modify group properties
modify_group() {
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

    # Extract the info of the group
    current_info=$(getent group "$groupname")
    IFS=':' read -ra group_data <<< "$current_info"
    current_gid=${group_data[2]}
    current_members=${group_data[3]}


    while true; do
        # Display modification menu and group info
        choice=$(whiptail --title "Modify Group: $groupname" --menu "\
            Current GID: $current_gid\n\
            Current Members: ${current_members:-None}\n\n\
            Select action:" 15 60 5 \
            "GID" "Change Group ID" \
            "Members" "Modify Group Members" \
            "Password" "Set Group Password" \
            "Done" "Finish Modifications" 3>&1 1>&2 2>&3)

        case $choice in
            GID)
                new_gid=$(whiptail --inputbox "Current GID: $current_gid\n\nEnter new GID:" 10 40 "$current_gid" 3>&1 1>&2 2>&3)
                [ $? -eq 0 ] && {
                    if sudo groupmod -g "$new_gid" "$groupname" 2>/tmp/groupmod_error; then
                        current_gid=$new_gid
                        show_success "GID changed to $new_gid!"
                    else
                        show_error "Failed to change GID:\n$(cat /tmp/groupmod_error)"
                        rm -f /tmp/groupmod_error
                    fi
                }
                ;;
            Members)
                all_users=$(awk -F: '($3 > 1000 && $3 != 65534) {printf "%s%s" , $1 , " | " } ' /etc/passwd)
                selected_members=$(whiptail --inputbox "Current Members: ${current_members:-None}\n\nAvailable Users: $all_users\n\nEnter members (comma separated):" 16 80 "$current_members" 3>&1 1>&2 2>&3)
                [ $? -eq 0 ] && {
                    # Clear existing members first
                    sudo gpasswd -M "" "$groupname" 2>/dev/null
                    # Add new members
                    IFS=',' read -ra new_members <<< "$selected_members"
                    for user in "${new_members[@]}"; do
                        sudo usermod -aG "$groupname" "$user" 2>/tmp/groupmem_error || {
                            show_error "Failed to add user '$user':\n$(cat /tmp/groupmem_error)"
                            rm -f /tmp/groupmem_error
                            continue
                        }
                    done
                    current_members=$(getent group "$groupname" | cut -d: -f4)
                    show_success "Group members updated!"
                }
                ;;
            Password)
                if sudo gpasswd "$groupname" 2>/tmp/gpasswd_error; then
                    show_success "Group password set successfully!"
                else
                    show_error "Failed to set group password:\n$(cat /tmp/gpasswd_error)"
                    rm -f /tmp/gpasswd_error
                fi
                ;;
            Done)
                show_success "Finished modifying group '$groupname'"
                return 0
                ;;
            *)
                return 1
                ;;
        esac
    done
}