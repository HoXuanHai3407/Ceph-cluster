# Update and install essential packages on all nodes
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget openssh-server

# On node-1, generate SSH key and distribute to other nodes
ssh-keygen -t rsa
ssh-copy-id user@192.168.1.102
ssh-copy-id user@192.168.1.103

# Important: Export the Ceph public key
ceph cephadm get-pub-key > ~/ceph.pub
# Copy the key to /root/.ssh/authorized_keys on other nodes

# Install Docker on all nodes
sudo apt install -y docker.io
sudo systemctl enable docker

# Set hostname on each node
sudo hostnamectl set-hostname node-1  # On node-1
sudo hostnamectl set-hostname node-2  # On node-2
sudo hostnamectl set-hostname node-3  # On node-3

# Update /etc/hosts on all nodes
sudo nano /etc/hosts
###########################
192.168.1.101 node-1
192.168.1.102 node-2
192.168.1.103 node-3
###########################

# Install Cephadm on node-1
curl -L -o cephadm https://raw.githubusercontent.com/ceph/ceph/quincy/src/cephadm/cephadm
chmod +x cephadm
sudo mv cephadm /usr/local/bin/
cephadm version
cephadm --image quay.io/ceph/ceph:v17 version

# Bootstrap the initial cluster on node-1
sudo cephadm bootstrap --mon-ip 192.168.1.101
sudo ceph -s

# Add other nodes to the cluster
ssh-copy-id user@192.168.1.102
ssh-copy-id user@192.168.1.103
ceph orch host add node-2 192.168.1.102
ceph orch host add node-3 192.168.1.103

# Deploy OSD services
ceph orch device ls
ceph orch daemon add osd node-1:/dev/sdb
ceph orch daemon add osd node-2:/dev/sdb
ceph orch daemon add osd node-3:/dev/sdb

# If disk addition fails, clear the disk
lsblk
sudo sgdisk --zap-all /dev/sdb
sudo dd if=/dev/zero of=/dev/sdb bs=1M count=10
sudo wipefs --all /dev/sdb

# Verify cluster status after adding OSD
ceph -s

# Cluster management commands
ceph orch ps
ceph orch <command>

# Access Ceph Dashboard
ceph dashboard ac-user-show-password
# Access the dashboard via browser: https://192.168.1.101:8443

# Create a new dashboard user
echo "SecureP@ssword123" > /tmp/dashboard_password
ceph dashboard ac-user-create admin -i /tmp/dashboard_password administrator
