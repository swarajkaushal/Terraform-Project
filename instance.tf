resource "aws_key_pair" "key-tf" {
  key_name   = "key-tf"
  public_key = file("${path.module}/id_rsa.pub")
}



resource "aws_vpc" "VPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Terraform-VPC"
  }
}

resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "internet-gateway"
  }
}
resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  depends_on = [ aws_internet_gateway.internet-gateway ]


  tags = {
    Name = "Terraform-public-subnet"
  }
}
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }
  tags = {
    Name = "pubicRT"
  }
}
resource "aws_route_table_association" "PSRT-association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"


  tags = {
    Name = "Terraform-private-subnet"
  }
}
resource "aws_security_group" "Security" {
  name        = "security"
  description = "Allow inbound traffic"
  vpc_id = aws_vpc.VPC.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
}


resource "aws_instance" "assigment" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.key-tf.key_name}"
  subnet_id = aws_subnet.public-subnet.id
  # vpc_security_group_ids = aws_security_group.security.id
  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags = {
    Name = "Assgment"
    purpose="Assigment"
  }
}