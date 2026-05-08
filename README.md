# Terraform AWS VPC Infrastructure Project

## Project Overview
This project demonstrates automated AWS infrastructure provisioning using Terraform with secure networking architecture, load balancing, and auto scaling.

## Architecture
Internet User
→ Application Load Balancer
→ Target Group
→ EC2 Instances in Private Subnet
→ NAT Gateway for outbound internet access

## Services Used
- Terraform
- AWS VPC
- Public and Private Subnets
- Internet Gateway
- NAT Gateway
- Application Load Balancer (ALB)
- Target Group
- Launch Template
- Auto Scaling Group
- EC2
- Security Groups

## Key Features
- Infrastructure as Code (IaC)
- Multi-tier AWS architecture
- Public and private subnet separation
- Load balancing using ALB
- Auto Scaling for high availability
- NAT Gateway for private subnet internet access
- Automated application deployment using User Data
- Reusable Terraform variables and outputs

## Terraform Concepts Used
- provider.tf
- variables.tf
- output.tf
- data sources
- resource blocks
- dependencies
- launch templates

## Traffic Flow
1. User sends request to ALB
2. ALB listener forwards request to Target Group
3. Target Group routes traffic to EC2 instances
4. EC2 instances serve the application
5. Private EC2 instances access internet through NAT Gateway

## Auto Scaling Workflow
- Launch Template defines EC2 configuration
- Auto Scaling Group launches EC2 automatically
- User data installs Apache and pulls code from GitHub
- New instances automatically register into Target Group

## Security Design
- ALB deployed in public subnets
- EC2 deployed in private subnet
- NAT Gateway used for outbound internet access
- Internet traffic restricted through load balancer

## Outcome
Successfully provisioned scalable and secure AWS infrastructure using Terraform automation.
