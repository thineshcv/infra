resource "aws_security_group" "ecs_tasks" {
  name        = "${var.cluster_name}-ecs-tasks"
  description = "Allow inbound from ALBs to ECS tasks"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-ecs-tasks"
  })
}

# Allow traffic from every ALB security group (external + internal)
resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb" {
  for_each = toset(var.alb_security_group_ids)

  security_group_id            = aws_security_group.ecs_tasks.id
  referenced_security_group_id = each.value
  from_port                    = 1
  ip_protocol                  = "tcp"
  to_port                      = 65535
}

resource "aws_vpc_security_group_egress_rule" "ecs_all_outbound" {
  security_group_id = aws_security_group.ecs_tasks.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
