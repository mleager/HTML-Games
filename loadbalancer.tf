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
      records = [module.alb.lb_dns_name]
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
    }
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

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "html-alb"

  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [module.alb_sg.security_group_id]

  target_groups = [
    {
      name                 = "landing-tg"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/healthz"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 6
        timeout             = 15
        protocol            = "HTTP"
        matcher             = "200"
      }
    },
    {
      name                 = "2048-tg"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/healthz"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 6
        timeout             = 15
        protocol            = "HTTP"
        matcher             = "200"
      }
    },
    {
      name                 = "floppybird-tg"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/healthz"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 6
        timeout             = 15
        protocol            = "HTTP"
        matcher             = "200"
      }
    },
    {
      name                 = "pong-tg"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/healthz"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 6
        timeout             = 15
        protocol            = "HTTP"
        matcher             = "200"
      }
    },
    {
      name                 = "tetris-tg"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/healthz"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 6
        timeout             = 15
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  ]

  https_listeners = [
    {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = module.acm.acm_certificate_arn
      #target_group_index = 0
    }
  ]

  https_listener_rules = [
    {
      https_listener_index = 0
      target_group_index   = 0
      priority             = 0

      actions = [{
        type     = "forward"
        protocol = "HTTPS"
      }]

      conditions = [{
        path_patterns = ["/"]
      }]
    },
    {
      https_listener_index = 0
      target_group_index   = 1
      priority             = 1

      actions = [{
        type     = "forward"
        protocol = "HTTPS"
      }]

      conditions = [{
        path_patterns = ["/2048*"]
      }]
    },
    {
      https_listener_index = 0
      target_group_index   = 2
      priority             = 2

      actions = [{
        type     = "forward"
        protocol = "HTTPS"
      }]

      conditions = [{
        path_patterns = ["/floppybird*"]
      }]
    },
        {
      https_listener_index = 0
      target_group_index   = 3
      priority             = 3

      actions = [{
        type     = "forward"
        protocol = "HTTPS"
      }]

      conditions = [{
        path_patterns = ["/pong*"]
      }]
    },
        {
      https_listener_index = 0
      target_group_index   = 4
      priority             = 4

      actions = [{
        type     = "forward"
        protocol = "HTTPS"
      }]

      conditions = [{
        path_patterns = ["/tetris*"]
      }]
    }
  ]

  tags = {
    Name = "html-alb"
  }
}
