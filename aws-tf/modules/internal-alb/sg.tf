resource "aws_security_group" "internal_lb" {
  name        = "${var.name}-sg"
  description = "Allow VPC traffic to internal ALB"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${var.name}-sg"
  })
}

# Allow inbound HTTP from anywhere within the VPC
resource "aws_vpc_security_group_ingress_rule" "from_vpc" {
  security_group_id = aws_security_group.internal_lb.id
  cidr_ipv4         = var.vpc_cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.internal_lb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
