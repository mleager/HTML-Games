data "aws_route53_zone" "main" {
  name = "mark-dns.de"
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "www.mark-dns.de"
  zone_id     = data.aws_route53_zone.main.id

  wait_for_validation = true
}

module "dns_record" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_id = data.aws_route53_zone.main.zone_id

  records = [
    {
      name    = "www"
      type    = "CNAME"
      ttl     = 3600
      records = [aws_lb.alb.dns_name] #module.alb.lb_dns_name
    }
  ]
}

module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~>5.0"

  name        = "alb-sg"
  description = "Security group for ALB"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS to ALB"
      cidr_blocks = "0.0.0.0/0"
    },
    # {
    #   from_port   = 80
    #   to_port     = 80
    #   protocol    = "tcp"
    #   description = "Allow HTTP to ALB"
    #   cidr_blocks = "0.0.0.0/0"
    # }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow All Egress from ALB"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

resource "aws_lb" "alb" {
  name               = "html-games-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.alb_sg.security_group_id]
  subnets            = module.vpc.public_subnets

  access_logs {
    bucket  = "tf-state-mentorship"
    prefix  = "test-lb"
    enabled = false
  }

  tags = {
    Name = "html-games-alb"
  }
}

resource "aws_lb_target_group" "tg_2048" {
  name     = "2048-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 30
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    timeout             = 25
  }
}

resource "aws_lb_target_group" "tg_floppybird" {
  name     = "floppybird-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    interval            = 30
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    timeout             = 25
  }
}

resource "aws_lb_target_group_attachment" "attach-target1" {
  target_group_arn = aws_lb_target_group.tg_2048.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach-target2" {
  target_group_arn = aws_lb_target_group.tg_floppybird.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = module.acm.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_2048.arn
  }
}

resource "aws_lb_listener_certificate" "listener_cert" {
  listener_arn    = aws_lb_listener.front_end.arn
  certificate_arn = module.acm.acm_certificate_arn
}

resource "aws_lb_listener_rule" "listener_2048" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_2048.arn
  }

  condition {
    path_pattern {
      values = ["/2048*"]
    }
  }
}

resource "aws_lb_listener_rule" "listener_floppybird" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_floppybird.arn
  }

  condition {
    path_pattern {
      values = ["/floppybird*"]
    }
  }
}

# module "alb" {
#   source  = "terraform-aws-modules/alb/aws"
#   version = "~> 8.0"

#   name = "html-alb"

#   load_balancer_type = "application"

#   vpc_id          = module.vpc.vpc_id
#   subnets         = module.vpc.public_subnets
#   security_groups = [module.alb_sg.security_group_id]

#   target_groups = [
#     {
#       name_prefix          = "2048-"
#       backend_protocol     = "HTTP"
#       backend_port         = 80
#       target_type          = "instance"
#       deregistration_delay = 10
#       my_target = {
#           target_id = #module.asg.instance_id
#           port = 80
#         }

#       health_check = {
#         enabled             = true
#         interval            = 30
#         path                = "/healthz"
#         port                = "traffic-port"
#         healthy_threshold   = 2
#         unhealthy_threshold = 3
#         timeout             = 6
#         protocol            = "HTTP"
#         matcher             = "200"
#       }
#     },
#     {
#       name_prefix          = "floppybird-"
#       backend_protocol     = "HTTP"
#       backend_port         = 80
#       target_type          = "instance"
#       deregistration_delay = 10

#       health_check = {
#         enabled             = true
#         interval            = 30
#         path                = "/healthz"
#         port                = "traffic-port"
#         healthy_threshold   = 2
#         unhealthy_threshold = 3
#         timeout             = 6
#         protocol            = "HTTP"
#         matcher             = "200"
#       }
#     }
#   ]

#   https_listeners = [
#     {
#       port            = 443
#       protocol        = "HTTPS"
#       certificate_arn = module.acm.acm_certificate_arn
#       #target_group_index = 0
#     }
#   ]

#   https_listener_rules = [
#     {
#       https_listener_index = 0
#       actions = [{
#         type     = "forward"
#         protocol = "HTTPS"
#       }]

#       conditions = [{
#         path_patterns = ["/2048*"]
#       }]
#     },
#     {
#       https_listener_index = 1
#       actions = [{
#         type     = "forward"
#         protocol = "HTTPS"
#       }]

#       conditions = [{
#         path_patterns = ["/floppybird*"]
#       }]
#     }
#   ]

#   tags = {
#     Name = "html-alb"
#   }
# }
