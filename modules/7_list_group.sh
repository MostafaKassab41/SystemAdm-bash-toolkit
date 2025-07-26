#!/bin/bash

# Import common functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/common.sh"


# List all groups with their members
list_groups() {
    groups=$(awk -F: '
    BEGIN {
    i=0 
    printf "%-4s%-19s %s\n", "No.", "Groups", "Users"
    printf "%-4s%-19s %s\n", "---", "------", "-----"
    }

    ($3 == 10 || ($3 > 1000 && $3 != 65534)){
    i++  # For the user number
    spaces_group = 4 - length(i) #spaces between the group and his number
    if (spaces_group < 3) {spaces_group = 3}  # At least 3 spaces between the group and his number
    spaces_users = 20 - length($1) -1  #spaces between the group and his users
    

    

    printf "%2s%*s%s%*s%s\n\n", i , spaces_group , "" , $1 , spaces_users , "" ,$4
    }' /etc/group)
    
    whiptail --title "System Groups" --msgbox --scrolltext "Groups and their members:\n\n$groups" 25 50
}

