#!/bin/bash

# Import common functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/common.sh"

# Function to display user creation summary
show_summary() {
    local username=$1
    local userid=$2
    local groupid=$3
    local subgroupid=$4
    local exp_date=$5
    local homedir=$6
    local shell=$7
    
    whiptail --title "User Creation Summary" --yesno \
        "Please review the user details before creation:\n\n\
        Username: $username\n\
        User ID: $userid\n\
        Group ID: $groupid\n\
        Supplementary Groups: $subgroupid\n\
        EXP date: $exp_date\n\
        Home Directory: $homedir\n\
        Shell: $shell\n\n\
        Create this user?" 16 60
            
            return $?
}


default_setting() {
    username=$(whiptail --title "Default setting" --inputbox "Enter username:" 8 40 3>&1 1>&2 2>&3)

    # Check if user pressed Cancel
    if [ $? -ne 0 ] ; then
        show_error "User creation cancelled."
        return
    fi

    # Checks if the username is empty.
    if [ -z "$username" ]; then
        show_error "Username cannot be empty!"
        return
    fi

    # Check if user already exists
    if id "$username" &>/dev/null; then
        show_error "User '$username' already exists!"
        default_setting
    fi

    # Create the user
    if sudo useradd -m "$username" 2>/tmp/useradd_error; then
        show_success "User '$username' created successfully!"
    else
        local error
        error=$(cat /tmp/useradd_error)
        show_error "Failed to create user '$username':\n$error"
        rm -f /tmp/useradd_error
    fi

}

custom_setting() {

    username=$(whiptail --title "Custom setting" --inputbox "Enter username:" 8 40 3>&1 1>&2 2>&3)
    # Check if user pressed Cancel
    if [ $? -ne 0 ] ; then
        show_error "User creation cancelled."
        return
    fi
    # Checks if the username is empty.
    if [ -z "$username" ]; then
        show_error "Username cannot be empty!"
        return
    fi
    # Check if user already exists
    if id "$username" &>/dev/null; then
        show_error "User '$username' already exists!"
        return
    fi

    userid=$(whiptail --inputbox "Enter User ID (leave empty for automatic):" 8 50 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ] ; then
        show_error "User creation cancelled."
        return
    fi

    groupid=$(whiptail --inputbox "Enter Primary Group ID or name(leave empty for automatic):" 8 50 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ] ; then
        show_error "User creation cancelled."
        return
    fi

    subgroupid=$(whiptail --inputbox "Enter Supplementary Groups (GROUP1,GROUP2,...,GROUPN):" 8 50 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ] ; then
        show_error "User creation cancelled."
        return
    fi

    exp_date=$(whiptail --inputbox "Enter the EXPIRE DATE (YYYY-MM-DD):" 8 50 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ] ; then
        show_error "User creation cancelled."
        return
    fi

    homedir=$(whiptail --inputbox "Enter Home Directory (leave empty for default):" 8 60 "/home/$username" 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ] ; then
        show_error "User creation cancelled."
        return
    fi

    shell=$(whiptail --inputbox "Enter Shell (leave empty for default):" 8 50 "/bin/bash" 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ] ; then
        show_error "User creation cancelled."
        return
    fi

    # Show summary and confirm
    if ! show_summary "$username" "$userid" "$groupid" "$subgroupid" "$exp_date" "$homedir" "$shell"; then
        show_error "User creation cancelled by user."
        return
    fi

    # Build the useradd command
    local useradd_cmd="useradd"
    
    [ -n "$userid" ] && useradd_cmd+=" -u $userid"
    [ -n "$groupid" ] && useradd_cmd+=" -g $groupid"
    [ -n "$subgroupid" ] && useradd_cmd+=" -G $subgroupid"
    [ -n "$exp_date" ] && useradd_cmd+=" -e $exp_date"
    [ -n "$homedir" ] && useradd_cmd+=" -d $homedir"
    [ -n "$shell" ] && useradd_cmd+=" -s $shell"
    
    useradd_cmd+=" -m $username"

    # Create the user
    if sudo $useradd_cmd 2>/tmp/useradd_error; then
        show_success "User '$username' created successfully!"
    else
        local error
        error=$(cat /tmp/useradd_error)
        show_error "Failed to create user '$username':\n$error"
        rm -f /tmp/useradd_error
    fi

}

create_new_user() {
    choice=$(whiptail --title "Main Menu" --menu "Choose an option" 20 50 10 \
        "1" "Use the default setting " \
        "2" "Use customized settings" \
        3>&1 1>&2 2>&3
        )


    
    case $choice in
            1) # Use the default setting
                default_setting
                ;;
            2) # Use customized settings
                custom_setting
                ;;
        esac




}
