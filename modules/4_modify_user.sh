#!/bin/bash

# Import common functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/common.sh"

modify_user() {
    # Get username to modify
    all_users=$(awk -F: '($3 > 1000 && $3 != 65534) {printf "%s%s" , $1 , " | " } ' /etc/passwd)
    username=$(whiptail --inputbox "Current Users:\n$all_users\n\nEnter username to modify:" 16 80 3>&1 1>&2 2>&3)
    
    [ $? -ne 0 ] && { show_error "Operation cancelled."; return; }
    [ -z "$username" ] && { show_error "Username cannot be empty!"; return; }

    # Verify user exists
    if ! id "$username" &>/dev/null; then
        show_error "User '$username' does not exist!"
        return
    fi

    while true; do
        # Get current user info
        current_info=$(getent passwd "$username")
        IFS=':' read -ra user_data <<< "$current_info"
        current_groups=$(id -Gn "$username" |  tr ' ' ',')
        locked_status=$(sudo passwd -S "$username" | awk '{print $2}')
        if [ "$locked_status" == "LK" ]; then
            current_lock="User is Locked"
        else
            current_lock="User UnLocked"
        fi
        current_expiry=$(sudo chage -l "$username" | grep "Account expires" | cut -d: -f2 | sed 's/^ //')
        [ "$current_expiry" == "never" ] && current_expiry="Not set"

        # Display modification menu
        choice=$(whiptail --title "Modify User: $username" --menu "\nCurrent Information:\n\
            Username: $username\n\n\
            Select attribute to modify:" 25 80 15 \
            "UID" "Change User ID" \
            "GID" "Change Group ID" \
            "Home" "Change Home Directory" \
            "Shell" "Change Login Shell" \
            "Groups" "Modify Group Memberships" \
            "Expiry" "Set Account Expiration" \
            "Lock" "Lock/Unlock Account ($current_lock)" \
            "Password" "Change Password" \
            "Done" "Finish Modifications" 3>&1 1>&2 2>&3)

        [ $? -ne 0 ] && { show_error "Modification cancelled."; return; }

        case $choice in
            UID)
                new_uid=$(whiptail --inputbox "Enter new UID:" 8 40 "${user_data[2]}" 3>&1 1>&2 2>&3)
                [ $? -eq 0 ] && sudo usermod -u "$new_uid" "$username" && \
                    show_success "UID changed successfully!" || \
                    show_error "Failed to change UID!"
                ;;
            GID)
                new_gid=$(whiptail --inputbox "Enter new GID:" 8 40 "${user_data[3]}" 3>&1 1>&2 2>&3)
                [ $? -eq 0 ] && sudo usermod -g "$new_gid" "$username" && \
                    show_success "GID changed successfully!" || \
                    show_error "Failed to change GID!"
                ;;
            Home)
                new_home=$(whiptail --inputbox "Enter new Home Directory:" 8 60 "${user_data[5]}" 3>&1 1>&2 2>&3)
                [ $? -eq 0 ] && sudo usermod -d "$new_home" -m "$username" && \
                    show_success "Home directory changed successfully!" || \
                    show_error "Failed to change home directory!"
                ;;
            Shell)
                new_shell=$(whiptail --inputbox "Enter new Shell:" 8 60 "${user_data[6]}" 3>&1 1>&2 2>&3)
                [ $? -eq 0 ] && sudo usermod -s "$new_shell" "$username" && \
                    show_success "Login shell changed successfully!" || \
                    show_error "Failed to change shell!"
                ;;
            Groups)
                all_groups=$(awk -F: '($3 > 1000 && $3 != 65534) || $3 == 10  {printf "%s%s" , $1 , " | " } ' /etc/group)
                selected_groups=$(whiptail --inputbox "Enter groups (comma separated):\n\nCurrent groups: $current_groups\n\nAvailable groups: $all_groups" 16 80 "$current_groups" 3>&1 1>&2 2>&3)
                [ $? -eq 0 ] && {
                    sudo usermod -G "$selected_groups" "$username" 2>/tmp/groupmod_error && \
                        show_success "Groups updated successfully!" || \
                        show_error "Failed to modify groups:\n$(cat /tmp/groupmod_error)"
                    rm -f /tmp/groupmod_error
                }
                ;;
            Expiry)
                expiry_date=$(whiptail --inputbox "Enter expiration date (YYYY-MM-DD):\n\nLeave empty for no expiration\nCurrent: $current_expiry" 11 60 3>&1 1>&2 2>&3)
                [ $? -eq 0 ] && {
                    if [ -z "$expiry_date" ]; then
                        sudo chage -E -1 "$username" && \
                            show_success "Expiration date removed!" || \
                            show_error "Failed to remove expiration date!"
                    else
                        sudo chage -E "$expiry_date" "$username" && \
                            show_success "Expiration date set to $expiry_date!" || \
                            show_error "Failed to set expiration date!"
                    fi
                }
                ;;
            Lock)
                if [ "$locked_status" == "LK" ] || [ "$locked_status" == "L" ]; then
                    sudo usermod -U "$username" && \
                        show_success "Account unlocked successfully!" || \
                        show_error "Failed to unlock account!"
                else
                    sudo usermod -L "$username" && \
                        show_success "Account locked successfully!" || \
                        show_error "Failed to lock account!"
                fi
                ;;
            Password)
                password=$(whiptail --passwordbox "Enter new password for $username:" 8 60 3>&1 1>&2 2>&3)
                [ $? -eq 0 ] && {
                    echo -e "$password\n$password" | sudo passwd "$username" &>/dev/null && \
                        show_success "Password changed successfully!" || \
                        show_error "Failed to change password!"
                }
                ;;
            Done)
                show_success "Finished modifying user '$username'"
                return 0
                ;;
        esac
    done
}