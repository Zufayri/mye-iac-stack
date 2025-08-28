#!/usr/bin/env bash
set -euo pipefail

# Terraform must already be applied
TF_OUTPUT=$(terraform output -json)

# Extract values with jq
BASTION_EIP=$(echo "$TF_OUTPUT" | jq -r '.bastion_eip.value')
NGINX_IPS=$(echo "$TF_OUTPUT" | jq -r '.nginx_private_ips.value[]')
WEBAPP_IPS=$(echo "$TF_OUTPUT" | jq -r '.webapp_private_ips.value[]')
DB_IPS=$(echo "$TF_OUTPUT" | jq -r '.db_private_ips.value[]')

# Write to Ansible inventory
ANSIBLE_INVENTORY_PATH="../ansible/inventories/dev/hosts.ini"

# Private SSH Keypath
BASTION_KEYPATH="~/.ssh/mye-bastion-key"
NGINX_KEYPATH="~/.ssh/mye-bastion-key"
WEBAPP_KEYPATH="~/.ssh/mye-bastion-key"
DB_KEYPATH="~/.ssh/mye-bastion-key"

cat > "$ANSIBLE_INVENTORY_PATH" <<EOF
[bastion]
bastion ansible_host=$BASTION_EIP ansible_user=ubuntu ansible_ssh_private_key_file=$BASTION_KEYPATH

[nginx]
$(for ip in $NGINX_IPS; do
  name="nginx-$(echo $ip | awk -F. '{print $3$4}')"
  echo "$name ansible_host=$ip ansible_user=ubuntu ansible_ssh_private_key_file=$BASTION_KEYPATH"
done)

[nginx:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -i $NGINX_KEYPATH -W %h:%p ubuntu@$BASTION_EIP"'

[webapp]
$(for ip in $WEBAPP_IPS; do
  name="webapp-$(echo $ip | awk -F. '{print $3$4}')"
  echo "$name ansible_host=$ip ansible_user=ubuntu ansible_ssh_private_key_file=$BASTION_KEYPATH"
done)

[webapp:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -i $WEBAPP_KEYPATH -W %h:%p ubuntu@$BASTION_EIP"'

[db]
$(for ip in $DB_IPS; do
  name="db-$(echo $ip | awk -F. '{print $3$4}')"
  echo "$name ansible_host=$ip ansible_user=ubuntu ansible_ssh_private_key_file=$BASTION_KEYPATH"
done)

[db:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -i $DB_KEYPATH -W %h:%p ubuntu@$BASTION_EIP"'
EOF

echo "✅ Inventory generated at $ANSIBLE_INVENTORY_PATH"
