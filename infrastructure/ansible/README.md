# Configuration as Code (Ansible)

This directory contains Ansible playbooks for configuring hosts and services.

## Structure

```
infrastructure/ansible/
├── site.yaml              # Main playbook
└── roles/
    ├── docker/            # Install Docker
    │   └── tasks/main.yaml
    ├── kubectl/          # Install kubectl
    │   └── tasks/main.yaml
    ├── helm/             # Install Helm
    │   └── tasks/main.yaml
    └── tls/              # Generate TLS certificates
        └── tasks/main.yaml
```

## Usage

```bash
cd infrastructure/ansible

# Run all roles
ansible-playbook -i inventory site.yaml

# Run specific role
ansible-playbook -i inventory site.yaml --tags docker
```

## Roles

### docker
Installs Docker Engine on target hosts.

### kubectl
Downloads and installs kubectl CLI.

### helm
Downloads and installs Helm package manager.

### tls
Generates self-signed TLS certificates for local development.

## Requirements

- Ansible 2.15+
- Python 3

## Inventory

Create an `inventory` file:

```ini
[webservers]
192.168.1.10
192.168.1.11

[all:vars]
ansible_user=ubuntu
ansible_python_interpreter=/usr/bin/python3
```
