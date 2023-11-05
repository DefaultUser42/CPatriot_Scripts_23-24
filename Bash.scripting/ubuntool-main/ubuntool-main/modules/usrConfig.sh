# Prompt the user for a list of admin users
echo "Enter a space-separated list of admin users:"
read -a admin_users

# Prompt the user for a list of standard users
echo 'Enter a space-separated list of standard users:'
read -a standard_users

# Get a list of all users on the system
all_users=$(cat /etc/passwd | cut -d ":" -f 1)

# Store the list of users that will be modified in an array
users_to_modify=()
echo "The following users will be modified:"
# Loop through the list of all users
for user in $all_users; do
# Get the UID of the current user
uid=$(id -u "$user")

# Check if the UID is between 0 and 999(to skip things like root or daemons)
if [ $uid -ge 0 ] && [ $uid -le 999 ]; then
# Skip this user
continue
fi
# Check if the current user is in the list of admin users or standard users
if [[ " ${admin_users[@]} " =~ " ${user} " ]] || [[ " ${standard_users[@]} " =~ " ${user} " ]]; then
# Add the user to the list of users to modify
users_to_modify+=($user)
echo "-$user"
fi
done

# Prompt the user for confirmation
read -p "Are you sure you want to continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
# The user did not confirm, so exit the script
exit
fi

# Loop through the list of users to modify
for user in "${users_to_modify[@]}"; do
# Check if the current user is in the list of admin users
if [[ " ${admin_users[@]} " =~ " ${user} " ]]; then
# Add the user to the sudo group and remove them from the admin group
usermod -aG sudo "$user"
usermod -aG adm "$user"
echo "$user set to admin" >> ubuntoollog
fi

# Check if the user is in the list of standard users
if [[ " ${standard_users[@]} " =~ " ${user} " ]]; then
# Remove the user from the sudo and admin groups
gpasswd -d "$user" sudo
gpasswd -d "$user" adm
echo "$user set to standard" >> ubuntoollog
fi
done
# Store the list of users that will be deleted in an array
users_to_delete=()

# Loop through the list of all users
for user in $all_users; do
# Skip the user "nobody"
if [ "$user" == "nobody" ]; then
continue
fi

# Get the UID of the current user
uid=$(id -u "$user")

# Check if the UID is between 0 and 999
if [ $uid -ge 0 ] && [ $uid -le 999 ]; then
# Skip this user
continue
fi

# Check if the current user is not in the list of admin users or standard users
if [[ ! " ${admin_users[@]} " =~ " ${user} " ]] && [[ ! " ${standard_users[@]} " =~ " ${user} " ]]; then
# Add the user to the list of users to delete
users_to_delete+=($user)
fi
done

# Echo the list of users that will be deleted
echo "The following users will be deleted:"
for user in "${users_to_delete[@]}"; do
echo "- $user"
done

# Prompt the user for confirmation
read -p "Are you sure you want to continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
# The user did not confirm, so exit the script
exit
fi

# Loop through the list of users to delete
for user in "${users_to_delete[@]}"; do
# Delete the user
userdel -r "$user"
echo "$user deleted" >> ubuntoollog
done
read -p "Press [ENTER] key to continue" fakeenter
