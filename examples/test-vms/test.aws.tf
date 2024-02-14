data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical's owner ID
}

resource "aws_security_group" "test" {
  name        = var.aws_resource_name
  description = "allow SSH inbound traffic to test instance"
  vpc_id      = module.aws_vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #Purely for test. Restrict when copy pasting for real usage
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.aws_resource_name
  }
}

resource "aws_instance" "test" {
  ami                    = data.aws_ami.ubuntu.id
  key_name               = "shan"
  instance_type          = "m5.large"
  subnet_id              = module.aws_vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.test.id]

  associate_public_ip_address = true

  tags = {
    Name = var.aws_resource_name
  }
}

output "aws_test_instance_public_ip" {
  value = aws_instance.test.public_ip
}
