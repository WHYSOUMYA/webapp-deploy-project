# Automated Web Application Deployment using AWS, Terraform, Docker and Jenkins.

## Overview:

This project demonstrates the deployment of a containerized Python web application on AWS using Infrastructure as Code with Terraform. The application is packaged with Docker, stored on Docker Hub, and deployed on an Amazon EC2 instance running inside a custom VPC.

After verifying the deployment, all AWS resources were removed using `terraform destroy` to avoid unnecessary cloud charges.

## Resources Used:

- AWS EC2
- AWS VPC
- Terraform
- Docker
- Docker Hub
- GitHub
- Jenkins
- Python (Flask)

## Project Structure:

```text
webapp-deploy-project/
│
├── app/
│   ├── app.py
│   ├── Dockerfile
│   ├── requirements.txt
│   └── templates/
│       └── index.html
│
├── terraform/
│   ├── provider.tf
│   ├── variables.tf
│   ├── vpc.tf
│   ├── security_group.tf
│   ├── ec2.tf
│   └── outputs.tf
│
├── Jenkinsfile
├── architecture-diagram.svg
└── README.md
```

## Infrastructure:

Terraform automatically creates the following AWS resources:

- Custom VPC
- Public Subnet
- Internet Gateway
- Route Table
- Security Group
- Amazon EC2 Instance

The EC2 instance installs Docker during startup and pulls the latest application image from Docker Hub.

## Docker:

Docker Hub Repository

```
sxumy4/webapp
```

Build the image:

```bash
cd app
docker build -t sxumy4/webapp:latest .
```

Push the image:

```bash
docker login
docker push sxumy4/webapp:latest
```

## Deploying the Infrastructure

Move into the Terraform directory.

```bash
cd terraform
```

Initialize Terraform.

```bash
terraform init
```

Review the execution plan.

```bash
terraform plan -var="key_name=webapp-key"
```

Deploy the infrastructure.

```bash
terraform apply -var="key_name=webapp-key"
```

After deployment, Terraform displays the EC2 public IP. Open the IP address in a browser to access the application.

## CI/CD Pipeline:

The Jenkins pipeline performs the following tasks:

- Clone the project from GitHub
- Run SonarQube analysis
- Build the Docker image
- Scan the image using Trivy
- Push the latest image to Docker Hub
- Deploy the updated container to the EC2 instance

## Workflow:

```text
Developer
    │
    ▼
GitHub Repository
    │
    ▼
Jenkins Pipeline
    │
    ├── SonarQube Analysis
    ├── Docker Build
    ├── Trivy Scan
    ├── Docker Push
    │
    ▼
Docker Hub
    │
    ▼
AWS EC2
    │
    ▼
Running Web Application
```

## Cleanup:
After testing the deployment, all AWS resources were removed using:

```bash
terraform destroy -var="key_name=webapp-key"
```

This deletes the EC2 instance, VPC, subnet, Internet Gateway, route table and security group created during deployment.

## Results:
The project successfully demonstrated:

- Docker containerization of a Flask web application.
- Infrastructure provisioning using Terraform.
- Deployment of the application on AWS EC2.
- Image storage using Docker Hub.
- Automated deployment workflow using Jenkins.
- Complete cleanup of AWS resources after deployment.