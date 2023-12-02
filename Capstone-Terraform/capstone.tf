#terraform
provider "aws" {
  region = "us-east-1"
}




resource "aws_vpc" "Capstone_VPC" {
  cidr_block       = "10.0.0.0/16"
  
  tags = {
    Name = "CapstoneVpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.Capstone_VPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.Capstone_VPC.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private"
  }
}

resource "aws_internet_gateway" "capstonegw" {
  vpc_id = aws_vpc.Capstone_VPC.id

  tags = {
    Name = "CapstoneIGW"
  }
}

resource "aws_route_table" "Publicrt" {
  vpc_id = aws_vpc.Capstone_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.capstonegw.id
  }

  
  tags = {
    Name = "Publicrt"
  }
}

resource "aws_route_table" "Privatert" {
 vpc_id = aws_vpc.Capstone_VPC.id

   route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.capstonegw.id
  }

  
  tags = {
    Name = "Privatert"
  }
 }

#  resource "aws_nat_gateway" "CapstoneNG" {
#   allocation_id = aws_eip.example.id
#   subnet_id     = aws_subnet.example.id

#   tags = {
#     Name = "gw NAT"
#   }

#   # To ensure proper ordering, it is recommended to add an explicit dependency
#   # on the Internet Gateway for the VPC.
#   depends_on = [aws_internet_gateway.example]
# }

resource "aws_route_table_association" "Capstonea" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.Publicrt.id
}

# resource "aws_route_table_association" "Capstoneb" {
#   gateway_id     = aws_internet_gateway.capstonegw.id
#   route_table_id = aws_route_table.Publicrt.id
# }

resource "aws_route_table_association" "Capstoneb" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.Privatert.id
}

#instance Security groups
resource "aws_security_group" "capstonesg" {
  name        = "capstonesg"
  description = "capstonesg"
  vpc_id      = aws_vpc.Capstone_VPC.id
  tags = {
    Name = "capstonesg"
  }
}


resource "aws_vpc_security_group_ingress_rule" "capstoneing" {
  security_group_id = aws_security_group.capstonesg.id
  
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 8080
  ip_protocol = "tcp"
  to_port     = 8080 # Allow traffic from any IP address (you may want to restrict this based on your needs)
  
}

resource "aws_vpc_security_group_ingress_rule" "capstoneing1" {
  security_group_id = aws_security_group.capstonesg.id
  
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22 # Allow traffic from any IP address (you may want to restrict this based on your needs)
  
}

#Databricks Instance
resource "aws_instance" "DataBricksInstance" {
  ami           = "ami-0fc5d935ebf8bc3bc"  
  instance_type = "t2.micro"  
  key_name      = "aws_key"  
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.capstonesg.id]
  associate_public_ip_address = true

  tags = {
    Name = "DataBricksInstance"
  }
}

#Jenkins Instance
resource "aws_instance" "JenkinsInstance" {
  ami           = "ami-0fc5d935ebf8bc3bc"  
  instance_type = "t2.micro"  
  key_name      = "aws_key"  
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.capstonesg.id]
  associate_public_ip_address = true

  tags = {
    Name = "JenkinsInstance"
  }
}

