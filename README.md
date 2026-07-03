# Automated Web Application Deployment using AWS, Terraform, Docker, and GitHub Actions

## Objective

Build and deploy a containerized web application on AWS using Infrastructure as Code and CI/CD automation.

## Tech Stack

- AWS EC2, AWS VPC
- Terraform
- Docker, Docker Hub
- GitHub
- Jenkins
- Linux (Amazon Linux 2023)

## Repository Structure

```
.
├── app/
│   ├── app.py
│   ├── requirements.txt
│   ├── Dockerfile
│   └── templates/
│       └── index.html
├── terraform/
│   ├── provider.tf
│   ├── variables.tf
│   ├── vpc.tf
│   ├── security_group.tf
│   ├── ec2.tf
│   └── outputs.tf
├── Jenkinsfile
├── architecture-diagram.svg
└── README.md
```

## Phase 1: AWS Infrastructure Setup (Terraform)

1. Install Terraform and configure AWS CLI credentials.
2. From the `terraform/` directory:

```
terraform init
terraform plan -var="key_name=your-ec2-key-pair"
terraform apply -var="key_name=your-ec2-key-pair"
```

This provisions:
- A VPC with a public subnet
- An internet gateway and route table
- A security group allowing SSH (22), HTTP (80), and the app port (5000)
- An EC2 instance that installs Docker on boot

3. Note the `instance_public_ip` output once apply completes.

## Phase 2: Docker Configuration

From the `app/` directory:

```
docker build -t yourdockerhubuser/webapp:latest .
docker login
docker push yourdockerhubuser/webapp:latest
```

Test locally before pushing:

```
docker run -p 5000:5000 yourdockerhubuser/webapp:latest
```

Visit `http://localhost:5000`.

## Phase 3: CI/CD Pipeline (Jenkins)

The `Jenkinsfile` defines a declarative pipeline with these stages:

1. Checkout source from GitHub
2. SonarQube static analysis with quality gate
3. Docker image build
4. Trivy vulnerability scan (high/critical severities)
5. Push image to Docker Hub
6. SSH into the EC2 instance and redeploy the container

### Jenkins setup notes

Configure these credentials in Jenkins before running the pipeline:

| Credential ID     | Type                | Purpose                          |
|--------------------|---------------------|-----------------------------------|
| dockerhub-creds    | Username/Password   | Docker Hub login                 |
| ec2-ssh-key        | SSH Username + Key  | SSH access to EC2 for deployment |
| ec2-host           | Secret text         | Public IP/DNS of the EC2 instance|

Install the required Jenkins plugins: Docker Pipeline, SSH Agent, SonarQube Scanner. Install `trivy` and `sonar-scanner` on the Jenkins agent, or run them as containers.

## Phase 4: Deployment

The EC2 user-data script pulls the image on first boot. Subsequent deployments are handled by the Jenkins pipeline's deploy stage, which SSHes into the instance, pulls the latest image, and restarts the container.

Once deployed, access the application at:

```
http://<ec2_public_ip>
```

## Architecture

See `architecture-diagram.svg` for the full flow: GitHub push triggers Jenkins, which builds, scans, and pushes the image to Docker Hub; the EC2 instance inside the VPC pulls and runs the updated container.

## Teardown

```
cd terraform
terraform destroy -var="key_name=your-ec2-key-pair"
```
