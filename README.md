# Ceph-Cluster
A comprehensive guide to deploying and managing a Ceph cluster for distributed storage systems.

## Description

Ceph is an open-source, distributed storage system that provides object, block, and file storage in a unified platform. It is highly scalable, resilient, and flexible, making it suitable for small-scale and enterprise-level deployments. This guide covers both quick and detailed methods to deploy a Ceph cluster using tools like Cephadm and Ansible.

## Install Cephadm on the Primary Node

This command downloads the Cephadm binary from the official Ceph repository and makes it executable. The `curl` command fetches the file, `chmod +x` assigns execution permissions, and `mv` moves the binary to a directory included in the system’s PATH for easy access.
```
curl -L -o cephadm https://raw.githubusercontent.com/ceph/ceph/quincy/src/cephadm/cephadm chmod +x cephadm sudo mv cephadm /usr/local/bin/

```
## Bootstrap the Cluster

The `cephadm bootstrap` command initializes a new Ceph cluster on the primary node. The `--mon-ip` flag specifies the IP address of the Monitor daemon, which manages the cluster map and ensures health and consistency across the nodes.
```
sudo cephadm bootstrap --mon-ip <PRIMARY_NODE_IP>
```
## Add Additional Nodes

The `ssh-copy-id` command copies the SSH key of the primary node to the other nodes, enabling passwordless SSH access. This is necessary for Cephadm to manage the cluster. The `ceph orch host add` command registers new nodes in the cluster by specifying their name and IP address.
```
ssh-copy-id root@<NODE_IP> ceph orch host add <NODE_NAME> <NODE_IP>
```
## Deploy OSDs

The `ceph orch device ls` command lists all available storage devices across the nodes. The `ceph orch daemon add osd` command assigns a specific device to the Object Storage Daemon (OSD) on a given node, enabling it to store data.
```
ceph orch device ls ceph orch daemon add osd <NODE_NAME>:/dev/<DEVICE>
```
## Verify the Cluster

The `ceph -s` command provides a summary of the cluster’s health and status, including the number of nodes, services, and the current state of the data replication and recovery processes.
```
ceph -s
```
## Access the Ceph Dashboard

After deploying the cluster, you can access the Ceph dashboard to monitor and manage the cluster. Use the following URL in your browser, replacing `<PRIMARY_NODE_IP>` with the Monitor node's IP address.
```
https://<PRIMARY_NODE_IP>:8443
```
## Conclusion

Deploying a Ceph cluster using Cephadm simplifies the process and ensures scalability and relia
