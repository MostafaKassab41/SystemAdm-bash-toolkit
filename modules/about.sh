#!/bin/bash

# Import common functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/common.sh"

about() {
    local version="1.0"
    local author="Mostafa Kassab"
    local email="mostafa.kassab41@gmail.com"
    local github="https://github.com/MostafaKassab41"
    
    whiptail --title "About User/Group Manager" --msgbox --scrolltext \
"User and Group Management Tool

Version: $version
Author: $author
Email: $email
GitHub: $github

Features:
- User Management
  ✓ Create users with custom UID/GID, home directory, and shell
  ✓ Modify all user attributes (including password/expiry)
  ✓ Safe deletion with home directory cleanup
  ✓ Interactive user listing with search capabilities

- Group management
  ✓ Create/delete groups with optional GID
  ✓ Comprehensive member management (add/remove users)
  ✓ Group password support
  ✓ Visual group hierarchy display

- Interactive whiptail interface

- Modular design for easy maintenance


TECHNICAL DETAILS:
• Built with: Bash 5.0+
• Dependencies: whiptail, sudo, coreutils
• Security: All operations require root privileges
" 20 70
}