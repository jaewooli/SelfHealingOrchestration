resource "aws_security_group" "vpc2_ecs_sg" {
  name   = "${local.name_prefix}-ecs-sg"
  vpc_id = aws_vpc.vpc2.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [local.vpc2_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "ir" {
  name = "${local.name_prefix}-ecs-cluster"

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/aws/ecs/${local.name_prefix}"
  retention_in_days = 14
}

resource "aws_ecs_task_definition" "ir_worker" {
  family                   = "${local.name_prefix}-ir-worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "ir-worker"
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "BUCKET_NAME"
          value = aws_s3_bucket.logs.bucket
        },
        {
          name  = "BEDROCK_MODEL_ID"
          value = var.bedrock_model_id
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "ir_worker" {
  name                   = "${local.name_prefix}-ir-worker"
  cluster                = aws_ecs_cluster.ir.id
  task_definition        = aws_ecs_task_definition.ir_worker.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = [aws_subnet.vpc2_private_a.id]
    security_groups  = [aws_security_group.vpc2_ecs_sg.id]
    assign_public_ip = false
  }
}