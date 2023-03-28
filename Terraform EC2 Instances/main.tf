provider "aws" {
  region = var.aws_region
}

# Get the latest AMI-ID.
data "aws_ssm_parameter" "ami_id" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}


# Get the AZs in the current region.
data "aws_availability_zones" "available" {}

# Select an availability zone from the list
locals {
  availability_zone = element(data.aws_availability_zones.available.names, var.availability_zone_index)
  subnet_id         = var.use_public_subnet ? aws_subnet.public_subnet.id : aws_subnet.private_subnet.id
}

# Create a new VPC with public and private subnets.
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = local.availability_zone
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = local.availability_zone
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  # A map of tags to assign to the resource.
  tags = {
    Name = "public"
  }
}

resource "aws_nat_gateway" "ngw" {
  # The Allocation ID of the Elastic IP address for the gateway.
  allocation_id = aws_eip.nat.id

  # The Subnet ID of the subnet in which to place the gateway.
  subnet_id = aws_subnet.public_subnet.id

  # A map of tags to assign to the resource.
  tags = {
    Name = "NAT Gateway"
  }
}

resource "aws_route_table" "private_route_table" {
  # The VPC ID.
  vpc_id = aws_vpc.my_vpc.id

  route {
    # The CIDR block of the route.
    cidr_block = "0.0.0.0/0"

    # Identifier of a VPC NAT gateway.
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  # A map of tags to assign to the resource.
  tags = {
    Name = "private"
  }
}

resource "aws_eip" "nat" {
  # EIP may require IGW to exist prior to association. 
  # Use depends_on to set an explicit dependency on the IGW.
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table_association" "public" {
  # The subnet ID to create an association.
  subnet_id = aws_subnet.public_subnet.id

  # The ID of the routing table to associate with.
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private" {
  # The subnet ID to create an association.
  subnet_id = aws_subnet.private_subnet.id

  # The ID of the routing table to associate with.
  route_table_id = aws_route_table.private_route_table.id
}

# Create a Security Group that is applied to the VPC above.
resource "aws_security_group" "public_security_group" {
  vpc_id = aws_vpc.my_vpc.id
  name   = join("_", ["public_sg", aws_vpc.my_vpc.id])
  dynamic "ingress" {
    for_each = var.rules
    content {
      from_port   = ingress.value["port"]
      to_port     = ingress.value["port"]
      protocol    = ingress.value["proto"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Terraform-Dynamic-Public-SG"
  }
}

resource "aws_security_group" "private_security_group" {
  vpc_id = aws_vpc.my_vpc.id
  name   = join("_", ["private_sg", aws_vpc.my_vpc.id])
  dynamic "ingress" {
    for_each = var.rules
    content {
      from_port       = ingress.value["port"]
      to_port         = ingress.value["port"]
      protocol        = ingress.value["proto"]
      cidr_blocks     = ingress.value["cidr_blocks"]
      security_groups = [aws_security_group.public_security_group.id]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Terraform-Dynamic-Private-SG"
  }
}

# Create the EC2 instances.
resource "aws_instance" "my-instance" {
  count         = var.instance_count
  ami           = data.aws_ssm_parameter.ami_id.value
  subnet_id     = local.subnet_id
  instance_type = var.instance_type
  vpc_security_group_ids = [
    aws_security_group.private_security_group.id,
    aws_security_group.public_security_group.id,
  ]
  availability_zone = local.availability_zone

  tags = {
    Name = "TerraformEC2Instance-${local.availability_zone}-${count.index + 1}"
  }
}