resource "aws_ecs_cluster" "this" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.tags
}

# --- Per-service resources ---

resource "aws_cloudwatch_log_group" "services" {
  for_each = var.services

  name              = "/ecs/${each.key}"
  retention_in_days = 7
  tags              = var.tags
}

resource "aws_ecs_task_definition" "services" {
  for_each = var.services

  family                   = each.key
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = each.value.task_cpu
  memory                   = each.value.task_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = each.value.container_name
      image     = each.value.container_image
      cpu       = each.value.task_cpu
      memory    = each.value.task_memory
      essential = true

      portMappings = [
        {
          containerPort = each.value.container_port
          hostPort      = each.value.container_port
          protocol      = "tcp"
        }
      ]

      environment = [for k, v in each.value.environment : { name = k, value = v }]

      secrets = [for k, v in each.value.secrets : { name = k, valueFrom = v }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.services[each.key].name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = var.tags
}

resource "aws_ecs_service" "services" {
  for_each = var.services

  name            = each.key
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.services[each.key].arn
  desired_count   = each.value.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  dynamic "load_balancer" {
    for_each = each.value.target_group_arns
    content {
      target_group_arn = load_balancer.value
      container_name   = each.value.container_name
      container_port   = each.value.container_port
    }
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_execution]

  tags = var.tags
}
