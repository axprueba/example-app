# main.tf

provider "aws" {
  region = "us-east-1" # Adjust as needed
}

# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

# Internet Gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
}

# Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Security Group
resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "app_instance" {
  ami             = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI in us-east-1
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.app_sg.name]
  key_name        = "my-key" # Replace with your SSH key name

  user_data = <<-EOF
              #!/bin/bash
              # Update and install Python
              yum update -y
              yum install -y python3 pip
              # Create app directory
              mkdir -p /home/ec2-user/app
              cd /home/ec2-user/app
              # Sample Python app
              echo "from http.server import SimpleHTTPRequestHandler, HTTPServer
              PORT = 80
              Handler = SimpleHTTPRequestHandler
              httpd = HTTPServer(('', PORT), Handler)
              print('serving at port', PORT)
              httpd.serve_forever()" > app.py
              # Start the Python app
              nohup python3 app.py &
            EOF

  tags = {
    Name = "PythonAppInstance"
  }
}

output "instance_public_ip" {
  value = aws_instance.app_instance.public_ip
}

