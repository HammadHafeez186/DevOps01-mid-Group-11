# Ansible Configuration Management

This directory contains Ansible playbooks for automating the deployment and configuration of the DevOps Articles application.

## Prerequisites

1. **Install Ansible**:
   ```bash
   pip install ansible
   ```

2. **Install required collections**:
   ```bash
   ansible-galaxy collection install -r requirements.yml
   ```

3. **Configure AWS CLI and kubectl**:
   ```bash
   aws configure
   aws eks update-kubeconfig --region us-east-1 --name devops-articles-cluster
   ```

## Files

- `playbook.yaml` - Main deployment playbook
- `hosts.ini` - Inventory file with host configuration
- `ansible.cfg` - Ansible configuration
- `requirements.yml` - Required Ansible collections

## Usage

### Run the full deployment playbook:

```bash
ansible-playbook playbook.yaml
```

### Check syntax:

```bash
ansible-playbook playbook.yaml --syntax-check
```

### Dry run (check mode):

```bash
ansible-playbook playbook.yaml --check
```

### Run specific tasks with tags:

```bash
ansible-playbook playbook.yaml --tags "deploy"
```

### Verbose output:

```bash
ansible-playbook playbook.yaml -v   # or -vv, -vvv for more verbosity
```

## What the Playbook Does

1. ✅ Verifies kubectl and AWS CLI installation
2. ✅ Configures kubectl for EKS cluster
3. ✅ Creates Kubernetes namespace
4. ✅ Applies ConfigMaps
5. ✅ Deploys PostgreSQL (if needed)
6. ✅ Deploys application
7. ✅ Applies services and HPA
8. ✅ Waits for pods to be ready
9. ✅ Displays deployment status and URLs

## Customization

Edit variables in `playbook.yaml`:
- `namespace` - Kubernetes namespace
- `cluster_name` - EKS cluster name
- `aws_region` - AWS region
- `ecr_registry` - ECR registry URL
- `image_tag` - Docker image tag

## Troubleshooting

### If kubectl not configured:
```bash
aws eks update-kubeconfig --region us-east-1 --name devops-articles-cluster
```

### If collections missing:
```bash
ansible-galaxy collection install kubernetes.core amazon.aws
```

### Check inventory:
```bash
ansible-inventory --list
```

### Test connection:
```bash
ansible all -m ping
```
