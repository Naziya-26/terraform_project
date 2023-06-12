resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = var.vpc_name
  }
}
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  count      = length(var.public_subnet_cidr_blocks)
  cidr_block = var.public_subnet_cidr_blocks[count.index]
  availability_zone      = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnet_name
  }
}
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  count      = length(var.private_subnet_cidr_blocks)
  cidr_block = var.private_subnet_cidr_blocks[count.index]
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = var.private_subnet_name
  }
}






data "aws_availability_zones" "available" {}

resource "aws_security_group" "public" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
  }

  ingress {
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
  }

  ingress {
    from_port   = var.docker_port
    to_port     = var.docker_port
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
  }

  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
  }

  ingress {
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.cidr_blocks
  }
}

resource "aws_security_group" "private" {
  vpc_id = aws_vpc.main.id
  count   = length(var.private_subnet_cidr_blocks)

  ingress {
    from_port   = var.ssh_port_private
    to_port     = var.ssh_port_private
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private[count.index].cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.cidr_blocks
  }
}
resource "aws_eip" "public_eip" {
  count         = length(aws_instance.public_instance)
  vpc           = true
  instance      = aws_instance.public_instance[count.index].id
  associate_with_private_ip = element(aws_instance.public_instance.*.private_ip, count.index)

  tags = {
    Name = "Public-EIP"
  }
}




resource "aws_eip" "nat_eip" {
  vpc = true

  tags = {
    Name = "NAT-Gateway-EIP"
  }
}


resource "aws_nat_gateway" "nat_gateway" {
  allocation_id  = aws_eip.nat_eip.id
  subnet_id      = aws_subnet.public[0].id

  tags = {
    Name = "NAT-Gateway"
  }
}



resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "VPC-Internet-Gateway"
  }
}

resource "aws_instance" "public_instance" {
  count           = var.public_instance_count
  ami              = var.centos_ami
  instance_type   = var.public_instance_type
  subnet_id        = aws_subnet.public[count.index].id
  user_data              = var.instance_user_data

  vpc_security_group_ids = [aws_security_group.public.id]

  tags = {
    Name = var.public_instance_name
  }
}

resource "aws_instance" "private_instance" {
  count           = var.private_instance_count
  instance_type   = var.private_instance_type
  ami              = var.centos_ami
  
  subnet_id        = aws_subnet.private[count.index].id
  vpc_security_group_ids = [aws_security_group.private[count.index].id]
  user_data              = var.instance_user_data_private
  
  tags = {
    Name = var.private_instance_name
  }
}


resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main-Route-Table"
  }
}

resource "aws_route" "public_internet_route" {
  route_table_id         = aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_subnet_association" {
  count           = length(var.public_subnet_cidr_blocks)
  subnet_id       = aws_subnet.public[count.index].id
  route_table_id  = aws_route_table.main.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Private-Route-Table"
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  count           = length(var.private_subnet_cidr_blocks)
  subnet_id       = aws_subnet.private[count.index].id
  route_table_id  = aws_route_table.private.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}
