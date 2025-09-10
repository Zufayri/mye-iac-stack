# AWS IaC with Terraform and Ansible

This repository demonstrates infrastructure provisioning, hardening, and deployment for a containerize web application using **Terraform**, **Ansible**, **Docker**, and **GitHub Actions**. The project includes best practices for networking, security, and automation.

---

## **Overview**

This project provisions a web application environment on **AWS**:

- **Bastion host**: Access point to private instances.  
- **Nginx server**: Reverse proxy and HTTP hardening.  
- **Webapp instances**: Containerized microservices (Python Flask).  
- **DB instance**: PostgreSQL container in private subnet.  
- **VPC**: Multi-subnet architecture with NAT gateway.  
- **Security**: Hardened OS, SSH hardening, Docker security practices.  

All infrastructure is fully automated using **Terraform** and **Ansible**.

---

## **Architecture**
```
+-----------------------------------------------------+
|                      Internet                       |
+-----------------------------------------------------+
        |                |                  |
  Bastion Host    Amazon Load Balancer  NAT Gateway
     (Public)         (Public)
         |               |                  |
         ----------------+-----------------
         |                                |
    Private Subnet 1                 Private Subnet 2
         |                                |
      Nginx                           Nginx
  (Private IP)                     (Private IP)
         |                                |
    Webapp + DB                     Webapp + DB
  (Private IP)                     (Private IP)
```
---

## **Features**

- **Terraform provisioning**:
  - VPC with multiple subnets and AZs  
  - Internet Gateway & NAT gateway  
  - Security groups  
  - EC2 instances for Bastion, Nginx, Webapp, and DB  

- **Ansible automation**:
  - System hardening (File update, UFW, Fail2ban)
  - SSH hardening (Prevent root ssh login, password login and max auth tries ssh)
  - Docker installation
  - Nginx
  - Deploy webapp containers
  - Deploy DB containers (PostgreSQL)

- **GitHub Actions CI/CD pipeline (WIP)**:
  - Terraform apply
  - Dynamic inventory generation
  - Ansible playbook execution

---

## **Prerequisites**

- AWS account with IAM access to EC2, VPC, Subnets, Security Groups  
- Terraform >= 1.5  
- Ansible >= 7.0  
- Python 3.11+  
- AWS cli configured 

---


## **Setup and Deployment** 

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/mye-bastion-key 

aws configure

cd terraform
terraform init
terraform plan
terraform apply -auto-approve

cd terraform
terraform init
terraform plan
terraform apply -auto-approve

ansible-playbook ansible/playbook.yml --ask-vault-pass
```

---

## **Security Notes**

- Use private subnets for DB and Webapp containers.

- Bastion host is the only public access point.

- SSH key is stored securely and not checked into the repository.

- Ansible Vault protects sensitive variables and credentials.

- NAT gateways provide controlled internet access to private instances.


---

## **Future Improvements**

- Add SSL termination with Nginx or AWS ALB

- Implement AWS WAF for HTTP protection

- Introduce ECS or EKS for container orchestration

- Add CI/CD testing stages for webapp

---


## **GitHub Actions CI/CD (WIP)**

The workflow automatically:

- Initializes and applies Terraform

- Generates inventory from Terraform outputs

- Runs Ansible playbook using the inventory

- Secrets stored in GitHub:

  - AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY → Terraform & AWS CLI

  - ANSIBLE_VAULT_PASSWORD → optional if automating vault pass via actions

  - SSH_PRIVATE_KEY → optional for connecting Bastion/instances
