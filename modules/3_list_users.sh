#!/bin/bash

display_users() {
# Defines the function to list users.
    users=$(awk -F: '
    BEGIN {
    i=0 
    printf "%-4s%-16s %s\n", "No.", "USERNAME", "LOGIN SHELL"
    printf "%-4s%-16s %s\n", "---", "--------", "-----------"
    }

    ($3 > 1000 && $3 != 65534) {
    i++  # For the user number
    spaces_user = 4 - length(i) #spaces between the user and his number
    if (spaces_user < 3) {spaces_user = 3}  # At least 3 spaces between the user and his number
    spaces_shell = 20 - length($1) -1  #spaces between the user and his shell
    

    if ($NF == "/bin/bash") { shell="bash"}
    else if ($NF == "/sbin/nologin") {shell="No Login"}
    else {shell= $NF}
    

    printf "%2s%*s%s%*s%s\n\n", i , spaces_user , "" , $1 , spaces_shell , "" ,shell
    }' /etc/passwd)
    
    whiptail --title "Users List" --msgbox --scrolltext "Users:\n$users" 20 50
    
}