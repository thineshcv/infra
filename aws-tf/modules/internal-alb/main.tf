# --- Internal Application Load Balancer ---
resource "aws_lb" "internal" {
  name               = var.name
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_lb.id]
  subnets            = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = var.name
  })
}

# --- One target group per service ---
resource "aws_lb_target_group" "services" {
  for_each = var.services

  name        = "${var.name}-${each.key}"
  port        = each.value.port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = each.value.health_check_path
    matcher             = "200"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${var.name}-${each.key}"
  })
}

# --- HTTP listener with a default 404 (routes are defined per-service below) ---
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "No route matched"
      status_code  = "404"
    }
  }
}

# --- Path-based routing rules ---
resource "aws_lb_listener_rule" "service_routes" {
  for_each = var.services

  listener_arn = aws_lb_listener.http.arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services[each.key].arn
  }

  condition {
    path_pattern {
      values = each.value.path_patterns
    }
  }
}
