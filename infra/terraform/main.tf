# Define team members
variable "team_members" {
  description = "Names of team members"
  type        = list(string)
  default     = ["Vivek M G (vm4512)", "Himasri ()", "Vignesh V (vv6644)"]
}

# Find the latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical owner ID
}

# Create a security group for the test instance
resource "aws_security_group" "instance_sg" {
  name        = "test-instance-sg"
  description = "Allow SSH, HTTP, and Expo Go connections"

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Expo Metro Bundler
  ingress {
    from_port   = 19000
    to_port     = 19000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # WebSocket debugger
  ingress {
    from_port   = 19001
    to_port     = 19001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Expo DevTools UI
  ingress {
    from_port   = 19002
    to_port     = 19002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # React Native packager
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "test-instance-sg"
  }
}

# Create a single EC2 instance for testing
resource "aws_instance" "test_instance" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t3.micro"
  security_groups = [aws_security_group.instance_sg.name]
  key_name        = "Wiiwake3101"  # SSH key for instance access

  tags = {
    Name        = "test-instance"
    Environment = "test"
    Owner       = var.team_members[0]
  }
}

# Output the public IP of the test instance
output "test_instance_ip" {
  value       = aws_instance.test_instance.public_ip
  description = "The public IP address of the test instance"
}