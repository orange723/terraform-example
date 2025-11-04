# provider 
# ###############################################################################
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.13.0"
    }
  }

  backend "s3" {
    bucket = ""
    key    = "terraform.tfstate"
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    endpoints = { s3 = "" }
  }
}

provider "aws" {
  profile = ""
  region  = ""
}

# resource
# ###############################################################################
data "aws_vpc" "vpc-uswest2-default" {
  id = ""
}

data "aws_subnet" "subnet-public-uswest2a-00" {
  id = ""
}

data "aws_subnet" "subnet-public-uswest2b-00" {
  id = ""
}

data "aws_subnet" "subnet-public-uswest2c-00" {
  id = ""
}

data "aws_subnet" "subnet-public-uswest2d-00" {
  id = ""
}

resource "aws_security_group" "group-alb-00" {
  name        = "group-alb-00"
  vpc_id      = data.aws_vpc.vpc-uswest2-default.id

  tags = {
    Name = "group-alb-00"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress-alb-00" {
  security_group_id = aws_security_group.group-alb-00.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "ingress-alb-01" {
  security_group_id = aws_security_group.group-alb-00.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "egress-alb-00" {
  security_group_id = aws_security_group.group-alb-00.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.group-alb-00.id]
  subnets            = [data.aws_subnet.subnet-public-uswest2a-00.id, data.aws_subnet.subnet-public-uswest2b-00.id, data.aws_subnet.subnet-public-uswest2c-00.id, data.aws_subnet.subnet-public-uswest2d-00.id]

  enable_deletion_protection = true
}

resource "aws_lb_listener" "listener-00" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
  certificate_arn   = ""

  routing_http_response_server_enabled = true
  routing_http_response_access_control_allow_credentials_header_value = true
  routing_http_response_access_control_allow_origin_header_value = "*"
  routing_http_response_access_control_allow_methods_header_value = "GET, POST, OPTIONS"
  routing_http_response_access_control_allow_headers_header_value = "*"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn = aws_lb_target_group.group-00.arn
      }
    }
  }
}

resource "aws_lb_target_group_attachment" "attachment-00" {
  target_group_arn = aws_lb_target_group.group-00.arn
  target_id        = "127.0.0.1"
  port             = 80
}

resource "aws_lb_target_group" "group-00" {
  name        = "group-00"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.vpc-uswest2-default.id

  health_check {
    enabled  = true
    interval = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    protocol = "HTTP"
    matcher  = "200-299"
    path     = "/"
    port     = 8080
    timeout  = 3
  }

  tags = {
    Domain = ""
  }
}

resource "aws_lb_listener_rule" "rule-00" {
  listener_arn = aws_lb_listener.listener-00.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.group-00.arn
  }

  condition {
    host_header {
      values = [""]
    }
  }
}