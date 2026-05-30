resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "${var.name}-nat-eip"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = var.public_subnet_ids[0] # in prod use nat gateway for each public subnet to increase availability

  tags = {
    Name = "${var.name}-nat-gw"
  }
}
