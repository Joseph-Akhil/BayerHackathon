resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "patient-appointment--eks-vpc"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
  Name = "eks-public-a"

  "kubernetes.io/cluster/patient-appointment-eks" = "shared"
  "kubernetes.io/role/elb"                         = "1"
}
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = true

  tags = {
  Name = "eks-public-b"

  "kubernetes.io/cluster/patient-appointment-eks" = "shared"
  "kubernetes.io/role/elb"                         = "1"
}
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "eu-central-1a"

  tags = {
  Name = "eks-private-a"

  "kubernetes.io/cluster/patient-appointment-eks" = "shared"
  "kubernetes.io/role/internal-elb"                = "1"
}
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "eu-central-1b"

  tags = {
  Name = "eks-private-b"

  "kubernetes.io/cluster/patient-appointment-eks" = "shared"
  "kubernetes.io/role/internal-elb"                = "1"
}
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-igw"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}
resource "aws_nat_gateway" "nat" {
  subnet_id     = aws_subnet.public_a.id
  allocation_id = aws_eip.nat_eip.id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "eks-nat"
  }
}
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "public_a_assoc" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b_assoc" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_a_assoc" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_b_assoc" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt.id
}