
resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/24"
    instance_tenancy = "default"
    enable_dns_hostnames = true
    tags = {
      Name = "test"
    }
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-west-1a"
    map_public_ip_on_launch = true
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
}
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

resource "aws_route_table_association" "association" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}
resource "aws_internet_gateway" "ig" {
    vpc_id = aws_vpc.main.id
}


resource "aws_security_group" "web_server_sec" {
    name = "web_server_sec"
    vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "ssh_inbound" {
    security_group_id = aws_security_group.web_server_sec.id
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "http_inbound" {
  security_group_id = aws_security_group.web_server_sec.id
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}

resource "aws_security_group_rule" "outbound" {
    security_group_id = aws_security_group.web_server_sec.id
    type = "egress"
    to_port = 0
    from_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  depends_on = [aws_eip.nat, aws_internet_gateway.ig]
}
