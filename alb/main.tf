terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "ap-south-1"
  profile = "aws-demo"
}



resource "aws_lb_target_group" "my-target-group" {
  
  health_check{
    interval                = 10
    path                    = "/"
    protocol                = "HTTP"
    timeout                 = 5
    healthy_threshold       = 5
    unhealthy_threshold     = 2
  }
   
  name     = "my-test-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}


resource "aws_lb" "my_aws_alb" {
  name               = "my-test-terraform-alb"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  security_groups    = [aws_security_group.my-alb-sg.id]
  subnets            = [var.subnet1,var.subnet2]

  enable_deletion_protection = true

  tags = {
    Name = "my-test-alb"
  }
}


resource "aws_lb_target_group_attachment" "my-alb-target-group-attachment1" {
  target_group_arn = "${aws_lb_target_group.my-target-group.arn}"
  target_id        = "${var.instance1_id}"
  port             = 80
}
resource "aws_lb_target_group_attachment" "my-alb-target-group-attachment2" {
  target_group_arn = "${aws_lb_target_group.my-target-group.arn}"
  target_id        = "${var.instance2_id}"
  port             = 80
}


resource "aws_lb_listener" "my-test-alb-listner" {
  load_balancer_arn = "${aws_lb.my_aws_alb.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.my-target-group.arn}"
  }
}



resource "aws_security_group" "my-alb-sg" {
  name   = "my-alb-sg"
  vpc_id = "${var.vpc_id}"
}

resource "aws_security_group_rule" "inbound_http" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.my-alb-sg.id}"
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_all" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.my-alb-sg.id}"
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}