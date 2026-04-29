# How to setup an Ubuntu NFS server on Ansible:

## This Playbook:
Installs nfs-kernel-server
Creates a shared directory /srv/nfs_share
Updates /etc/exports to export it
Enables and starts the NFS service

## Prerequisites

A control node with Ansible installed
A target Ubuntu machine (or VM) that will be your NFS server
SSH access from the control node to the target machine
Root privileges or become: true available


### Basic Directory Structure
nfs-setup/
├── inventory.ini
├── nfs-server.yml
└── files/

### Inventory File (inventory.ini)
[nfs_server]
10.11.11.66 ansible_user=ubuntu

##Playbook
```yaml
- name: Set up NFS server on Ubuntu
  hosts: nfs_server
  become: true

  vars:
    nfs_export_dir: "/srv/nfs_share"
    nfs_network_range: "192.168.1.0/24"

  tasks:
    - name: Install NFS server packages
      apt:
        name: nfs-kernel-server
        state: present
        update_cache: true

    - name: Create export directory
      file:
        path: "{{ nfs_export_dir }}"
        state: directory
        owner: nobody
	group: nogroup
        mode: '0777'

    - name: Configure /etc/exports
      lineinfile:
        path: /etc/exports
        line: "{{ nfs_export_dir }} {{ nfs_network_range }}(rw,sync,no_subtree_check)"
        create: yes
        state: present
    - name: Export the shares
      command: exportfs -ra

    - name: Ensure NFS service is enabled and running
      service:
        name: nfs-kernel-server
        state: started
        enabled: true
```

## from the nfs-setup directory run:

```bash
ansible-playbook -i inventory.ini nfs-server.yml
```


