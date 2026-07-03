data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name               = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    set -e
    yum update -y
    yum install -y docker
    systemctl enable docker
    systemctl start docker
    usermod -aG docker ec2-user
    docker pull ${var.docker_image}
    docker run -d --restart unless-stopped -p 80:${var.app_port} --name webapp ${var.docker_image}
  EOF

  tags = {
    Name = "${var.project_name}-instance"
  }
}
