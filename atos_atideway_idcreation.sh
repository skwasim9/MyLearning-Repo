#!/bin/bash

###########################################################################################################################################
###########################################################################################################################################
### Creating atideway ID and copy SSH key in authorize file with logging                                                                ###
### 29th June 2025 - Initial Release                                                                                                    ###
### Author - Atos Automation and GDTS Engineering - Wasim Mohammed Hanif Shaikh (1620060)                                               ###
###########################################################################################################################################
###########################################################################################################################################

set -e

USERNAME="atideway"
USER_UID=4399
USER_GID=4399
HOME_DIR="/home/$USERNAME"
SSH_KEY="AAAAB3NzaC1yc2EAAAABIwAAAQEA25zBXGJKgZ8IjCcoUEsxufvXKMLh9reQq3W7AVxyLbYoHTHe2J1CxEXgtTKF8E8H9YtsqEevCLdURO2CdjidUFBmSTb7O1NGcOb4i/B75S7RlF6RX80ZdMvS6jVrYwr05k9sHCXDH73vM6qO6JVzNQpRfXAQYoIhzLXDAutYW6Rw5ocAJCevzoFP61hTQtHlFTYahSNOgJmTy+7Qifz5q9hd/XeDrBx802gbutajL8PB2f+mlU0KrkDwFKBB39em7MYS5Ka2QoJvtLeHuyQTD/zORwQNmmlVTP9Z+ITY6lFYv8j8z2XhCrC/eoE2Jnh5C9kQgX7Ih8H7zJwAGb32Ow== atostideway@d71"

# Create group if not exists
if ! getent group "$USERNAME" > /dev/null; then
    groupadd -g "$USER_GID" "$USERNAME"
    echo "Group '$USERNAME' created with GID $USER_GID."
fi

# Checking user atideway is exists or not
if id "$USERNAME" &>/dev/null; then
    echo "User '$USERNAME' already exists. Verifying attributes..."

    CURRENT_UID=$(id -u "$USERNAME")
    CURRENT_GID=$(id -g "$USERNAME")
    CURRENT_HOME=$(getent passwd "$USERNAME" | cut -d: -f6)

    [[ "$CURRENT_UID" -ne "$USER_UID" ]] && echo "Warning: UID mismatch. Expected: $USER_UID, Found: $CURRENT_UID"
    [[ "$CURRENT_GID" -ne "$USER_GID" ]] && echo "Warning: GID mismatch. Expected: $USER_GID, Found: $CURRENT_GID"
    [[ "$CURRENT_HOME" != "$HOME_DIR" ]] && echo "Warning: Home directory mismatch. Expected: $HOME_DIR, Found: $CURRENT_HOME"

else
    echo "Creating user '$USERNAME' with UID $USER_UID, GID $USER_GID..."
    useradd -u "$USER_UID" -g "$USER_GID"  -c "atideway Account" -m  -d "$HOME_DIR" "$USERNAME"
    chage -M -1 -m 0 -I -1 -W 7 "$USERNAME"
    echo "User '$USERNAME' created successfully."
fi

# copy a SSH key
SSH_DIR="$HOME_DIR/.ssh"
mkdir -p "$SSH_DIR"
echo "$SSH_KEY" > "$SSH_DIR/authorized_keys"

# Set ssh key file permissions
chown -R "$USERNAME:$USERNAME" "$SSH_DIR"
chown root:root "$SSH_DIR/authorized_keys"
chmod 700 "$SSH_DIR"
chmod 640 "$SSH_DIR/authorized_keys"

echo "SSH key successfully added for user '$USERNAME'."
echo "Script completed."