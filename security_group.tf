resource "aws_security_group" "NAT_instance_sg" {
  name        = "NAT_instance_sg"
  description = "Security group for the NAT instance"
  vpc_id      = var.vpc_id
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

# inbound http from private subnets
resource "aws_vpc_security_group_ingress_rule" "NAT_instance_ingress_http" {
  security_group_id = aws_security_group.NAT_instance_sg.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = data.aws_vpc.vpc.cidr_block
  description       = "NAT_instance_ingress_http"
}

# inbound https from private subnets
resource "aws_vpc_security_group_ingress_rule" "NAT_instance_ingress_https" {
  security_group_id = aws_security_group.NAT_instance_sg.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = data.aws_vpc.vpc.cidr_block
  description       = "NAT_instance_ingress_https"
}

# inbound ssh from private subnets
resource "aws_vpc_security_group_ingress_rule" "NAT_instance_ingress_ssh" {
  count = var.use_ssh ? 1 : 0
  security_group_id = aws_security_group.NAT_instance_sg.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "0.0.0.0/0"
  description       = "allow ssh"
}

# outbound http to the internet
resource "aws_vpc_security_group_egress_rule" "NAT_instance_egress_http" {
  security_group_id = aws_security_group.NAT_instance_sg.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
  description       = "NAT_instance_egress_http"
}

# outbound https to the internet
resource "aws_vpc_security_group_egress_rule" "NAT_instance_egress_https" {
  security_group_id = aws_security_group.NAT_instance_sg.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
  description       = "NAT_instance_egress_https"
}
# outbound ssh to the internet
resource "aws_vpc_security_group_egress_rule" "NAT_instance_egress_ssh" {
  count = var.use_ssh ? 1 : 0
  security_group_id = aws_security_group.NAT_instance_sg.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "0.0.0.0/0"
  description       = "NAT_instance_egress_ssh"
}