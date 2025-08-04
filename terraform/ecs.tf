resource "aws_ecs_cluster" "file_upload_cluster" {
  name = "file-upload-cluster"
}


resource "aws_ecs_task_definition" "backend_task" {
  family                   = "file-upload-backend"
  cpu                      = "256"
  memory                   = "512"
  network_mode            = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "file-upload-backend"
      image     = "${aws_ecr_repository.backend_repo.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/file-upload-backend"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "backend_service" {
  name            = "file-upload-backend-service"
  cluster         = aws_ecs_cluster.file_upload_cluster.id
  task_definition = aws_ecs_task_definition.backend_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_groups = [aws_security_group.ecs-task-sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "file-upload-backend"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.http_listener]
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "ecs_backend_log_group" {
  name              = "/ecs/file-upload-backend"
  retention_in_days = 14 # 可根据需要改为 7/30/永不过期
}