# Linux User and Group Management Script

SystemAdm is an interactive, menu-driven Bash toolkit designed for system administrators to manage users and groups easily from the terminal. It simplifies common system administration tasks using a `whiptail`-based graphical interface.

## 🖼 Main menu

![Main_Menu](/ScreenShots/menu.jpg)

---

## 🌟 Features

🧑 **User Management**
- ✅ **Create users** with custom UID/GID, home dir, and shell  
- 🔄 **Modify users**: Password, expiry, lock/unlock, groups  
- 🗑️ **Delete users** with home directory cleanup  
- 📋 **List users** with searchable output  

👥 **Group Management**
- ➕ **Create/delete groups** with optional GID  
- 👥 **Manage memberships**: Add/remove users interactively  
- 🔒 **Group passwords** and admin control  

📋 **About**
- Displays information about the toolkit

---

## 📁 Folder Structure

```
.
├── sys_adm.sh                 # Main entry point (menu interface)
├── modules/
|   ├── 1_create_user.sh       # Add user script
|   ├── 2_delete_user.sh       # Delete user script
|   ├── 3_list_users.sh        # List users
|   ├── 4_modify_user.sh       # Modify user properties
|   ├── 5_create_group.sh      # Add group script
|   ├── 6_delete_group.sh      # Delete group script
|   ├── 7_list_group.sh        # List groups
|   ├── 8_modify_group.sh      # Modify group properties
|   ├── about.sh               # Info about the script
|   └── common.sh              # Common utility functions (e.g., check_root)
```


---

## 🚀 Quick Start
🧰 **Requirements**
- Linux OS 
- Bash 5.0+
- "whiptail" package installed (sudo apt install whiptail on Debian/Ubuntu)
- Root/sudo access

📦 **Installation**
```bash
git clone https://github.com/MostafaKassab41/SystemAdm-bash-toolkit.git
cd SystemAdm-bash-toolkit
chmod +x sys_adm.sh
```

✅ **Usage**
```bash
sudo ./sys_adm.sh
```

---

## 🖥️ Screenshots
***Some screenshots while using..
You can find more under ScreenShots/***

🧑 **User Management**

![User_list](/ScreenShots/user_list.jpg)  

![User_Modify](/ScreenShots/user_mod.jpg)

![User_Delete_conf](/ScreenShots/user_del2.jpg)


👥 **Group Management**

![group_list](/ScreenShots/group_list.jpg)    

![Group_Modify](/ScreenShots/group_mod.jpg)

![User_Delete](/ScreenShots/group_del.jpg) 

---

## 👨‍💻 Author
Mostafa Kassab

## ✅ Acknowledgments
- Inspired by the need for a simple, script-based administration tool.
- Thanks to the whiptail community for providing a robust text-based UI solution.

## 📧 Contact
For questions or support, please open an issue on the GitHub repository or contact the maintainer at mostafa.kassab41@gmail.com

