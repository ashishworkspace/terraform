provider "aws" {
  region  = "ap-south-1"
  profile = "default"
}


resource "aws_vpc" "terraform-vpc" {
  cidr_block                       = "10.10.0.0/16"
  enable_dns_hostnames             = true
  enable_dns_support               = true
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "terraform-vpc"
  }
}

resource "aws_subnet" "terraform-subnet-01" {
  vpc_id            = aws_vpc.terraform-vpc.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "terraform-subnet-01"
  }
}
resource "aws_subnet" "terraform-subnet-02" {
  vpc_id            = aws_vpc.terraform-vpc.id
  cidr_block        = "10.10.2.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "terraform-subnet-02"
  }
}
resource "aws_subnet" "terraform-subnet-03" {
  vpc_id            = aws_vpc.terraform-vpc.id
  cidr_block        = "10.10.3.0/24"
  availability_zone = "ap-south-1c"
  tags = {
    Name = "terraform-subnet-03"
  }
}

resource "aws_internet_gateway" "terraform-ig" {
  vpc_id = aws_vpc.terraform-vpc.id
  tags = {
    Name = "terraform-ig"
  }
}



resource "aws_route_table" "terraform-router" {
  vpc_id = aws_vpc.terraform-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-ig.id
  }
  tags = {
    Name = "terraform-router"
  }
}

resource "aws_route_table_association" "terraform-attach-subnet" {
  subnet_id      = aws_subnet.terraform-subnet-01.id
  route_table_id = aws_route_table.terraform-router.id
}

resource "aws_eip" "random-ip" {
  vpc = true
  tags = {
    Name = "random-ip"
  }
}

resource "aws_nat_gateway" "terraform-nat-gw" {
  allocation_id = aws_eip.random-ip.id
  subnet_id     = aws_subnet.terraform-subnet-01.id

  tags = {
    Name = "terraform-nat-gw"
  }
}

resource "aws_route_table" "terraform-nat-gw-route-table" {
  vpc_id = aws_vpc.terraform-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.terraform-nat-gw.id
  }
}

resource "aws_route_table_association" "terraform-assign-nat-to-subnet" {
  subnet_id      = aws_subnet.terraform-subnet-02.id
  route_table_id = aws_route_table.terraform-nat-gw-route-table.id
}


resource "aws_security_group" "terraform-sg" {
  name        = "terraform-sg"
  description = "terraform security group"
  vpc_id      = aws_vpc.terraform-vpc.id

  ingress {
    description = "Inbound Rule"
    from_port   = 22
    to_port     = 22
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
    Name = "terraform-sg"
  }
}

variable "ami" {
  type    = string
  default = "ami-04893cdb768d0f9ee"
}

resource "aws_key_pair" "terraform-key" {
  key_name   = "terraform-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDPPzCJLi0i4vs+lrM6EKajn1clsOUaHB9dgyfk+0XOzok8//Cd5xTPiqO1K87X1yGSJd3xam5XtTtYUDFA2EdtWKYa0apXaBEqqw/RdiioU1HCg0DH9cYIoEXkx9OLDtsjPDB+azHmmrOfyoIJVY7mViWLLnOucvDiebkcBzLuVjUUlKlOpwpzK5gal5YTeBo0Rv/WtZYKrHNJmpREFh61iqN9a7UIs0NscdI23y8tjE+Bw9fQ4e/atPfaf7GOAwvbHIrJRA2bawzPmqIWlo4U8Vizzh75k5PBcNSEtj3UHtUFpJctRP6Op2V++Y4+/23aWhZMC6MU1Txo2XpDzBkFrPxGGakh0vwfQIteIr98rvkmFoIda4zVELppWIJmH397xWOvxEaT4rMmoA7AAB5EJpJZ4v614drX03Z9x3qJXCI820w+MMYAtTSklZxfrIEudZlJBS5zWYVxViQWd+opiATTM1pB5KDTc8oYBO1wapJsemi67CII/ddSaEC5pm0= getma@DESKTOP-59V52CL"
}

resource "aws_instance" "terraform-instance" {
  ami                         = var.ami
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.terraform-subnet-01.id
  security_groups             = [aws_security_group.terraform-sg.id]
  key_name                    = "terraform-key"
  associate_public_ip_address = true
  tags = {
    Name = "terraform-instance-25-03-2022"
  }
}


resource "aws_security_group" "terraform-sg-private" {
  name        = "terraform-sg-private"
  description = "terraform security[private] group"
  vpc_id      = aws_vpc.terraform-vpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    Name = "terraform-sg-[private]"
  }
}
resource "aws_instance" "terraform-instance-private" {
  ami             = var.ami
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.terraform-subnet-02.id
  security_groups = [aws_security_group.terraform-sg-private.id]
  key_name        = "terraform-key"
  tags = {
    Name = "terraform-instance-25-03-2022-[private]"
  }
}
