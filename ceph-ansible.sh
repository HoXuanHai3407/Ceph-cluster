#!/bin/bash

# Ceph Cluster Deployment Script
# A script to automate the deployment of a Ceph cluster using ceph-ansible.

# Step 1: Install ceph-ansible on the primary node
echo "Step 1: Installing ceph-ansible..."
sudo git clone https://github.com/ceph/ceph-ansible.git /opt/ceph-ansible
cd /opt/ceph-ansible || exit
sudo git checkout stable-6.0
sudo apt update && sudo apt install -y python3-pip
sudo pip3 install -r requirements.txt

# Step 2: Configure hostnames
echo "Step 2: Configuring hostnames..."
sudo bash -c 'cat <<EOF > /etc/hosts
<PRIMARY_NODE_IP> ceph-v1
<NODE_2_IP> ceph-v2
<NODE_3_IP> ceph-v3
EOF'

# Step 3: Set up SSH between nodes
echo "Step 3: Setting up SSH between nodes..."
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
ssh-copy-id root@ceph-v1
ssh-copy-id root@ceph-v2
ssh-copy-id root@ceph-v3

# Step 4: Verify SSH connections
echo "Step 4: Verifying SSH connections..."
ssh ceph-v1 echo "SSH connection to ceph-v1 successful"
ssh ceph-v2 echo "SSH connection to ceph-v2 successful"
ssh ceph-v3 echo "SSH connection to ceph-v3 successful"

# Step 5: Configure the inventory file
echo "Step 5: Configuring the inventory file..."
sudo mkdir -p /etc/ansible
sudo bash -c 'cat <<EOF > /etc/ansible/hosts
[mons]
ceph-v1
ceph-v2
ceph-v3

[osds]
ceph-v1
ceph-v2
ceph-v3

[mgrs]
ceph-v1

[grafana-server]
ceph-v1
EOF'

# Step 6: Create and modify configuration files
echo "Step 6: Configuring ceph-ansible variables..."
cd /opt/ceph-ansible || exit
sudo cp site.yml.sample site.yml
cd group_vars || exit
sudo cp all.yml.sample all.yml
sudo cp osds.yml.sample osds.yml

# Modify 'all.yml'
sudo bash -c 'cat <<EOF > all.yml
ceph_origin: repository
ceph_repository: community
ceph_stable_release: pacific
monitor_interface: ens0
journal_size: 5120
cluster_network: <CLUSTER_NETWORK_SUBNET>
dashboard_enabled: True
dashboard_admin_user: admin
dashboard_admin_password: admin123
grafana_admin_user: admin
grafana_admin_password: admin123
EOF'

# Modify 'osds.yml'
sudo bash -c 'cat <<EOF > osds.yml
devices:
  - /dev/vdb
osd_auto_discovery: true
EOF'

# Step 7: Run Ansible playbook
echo "Step 7: Running Ansible playbook..."
ansible-playbook site.yml

# Step 8: Access the Ceph Dashboard
echo "Step 8: Verify and access the Ceph dashboard..."
echo "The dashboard can be accessed at: https://<PRIMARY_NODE_IP>:8443"

# Optional: Verify versions
echo "Verifying versions..."
python3 --version
ansible --version

echo "Ceph cluster deployment completed successfully!"
