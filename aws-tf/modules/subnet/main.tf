locals {
  public_subnets  = zipmap(var.az, var.public_cidr)
  private_subnets = zipmap(var.az, var.private_cidr)
}

resource "aws_subnet" "public" {
  for_each          = local.public_subnets
  vpc_id            = var.vpc_id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name : "subnet-public-${each.key}"
  }
}



resource "aws_subnet" "private" {
  for_each          = local.private_subnets
  vpc_id            = var.vpc_id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name : "subnet-private-${each.key}"
  }
}
