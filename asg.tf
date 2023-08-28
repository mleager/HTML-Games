data "aws_ami" "amazonlinux2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

module "private_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~>5.0"

  name        = "private-sg"
  description = "Allow HTTP Traffic from ALB"
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow All Egress"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "asg_landing" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.10.0"

  name = "asg-landing"

  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.private_subnets
  force_delete              = true

  target_group_arns = [module.alb.target_group_arns[0]]

  launch_template_name        = "html-lt-landing"
  launch_template_description = "Landing Page Launch template for HTML Games"
  update_default_version      = true
  launch_template_version     = "$Latest"

  instance_name   = "landing"
  image_id        = data.aws_ami.amazonlinux2.id
  instance_type   = "t2.micro"
  security_groups = [module.private_sg.security_group_id]
  user_data       = filebase64("scripts/landing-page.sh")

  create_iam_instance_profile = true
  iam_role_name               = "ssm-s3-iam-profile"
  iam_role_path               = "/ec2/"
  iam_role_description        = "IAM role for S3 and SSM Access to EC2"
  iam_role_tags = {
    CustomIamRole = "Yes"
  }
  iam_role_policies = {
    AmazonS3FullAccess           = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = {
    Environment = "Terraform"
    Name        = "html-games-0"
  }
}

module "asg_2048" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.10.0"

  name = "asg-2048"

  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.private_subnets
  force_delete              = true

  target_group_arns = [module.alb.target_group_arns[1]]

  launch_template_name        = "html-lt-2048"
  launch_template_description = "2048 Launch template for HTML Games"
  update_default_version      = true
  launch_template_version     = "$Latest"

  instance_name   = "2048"
  image_id        = data.aws_ami.amazonlinux2.id
  instance_type   = "t2.micro"
  security_groups = [module.private_sg.security_group_id]
  user_data       = filebase64("scripts/game-2048.sh")

  create_iam_instance_profile = true
  iam_role_name               = "ssm-iam-profile"
  iam_role_path               = "/ec2/"
  iam_role_description        = "IAM role for S3 and SSM Access to EC2"
  iam_role_tags = {
    CustomIamRole = "No"
  }
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = {
    Environment = "Terraform"
    Name        = "html-games-1"
  }
}

module "asg_floppybird" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.10.0"

  name = "asg-floppybird"

  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.private_subnets
  force_delete              = true

  target_group_arns = [module.alb.target_group_arns[2]]

  launch_template_name        = "html-lt-floppybird"
  launch_template_description = "Floppybird Launch template for HTML Games"
  update_default_version      = true
  launch_template_version     = "$Latest"

  instance_name   = "floppybird"
  image_id        = data.aws_ami.amazonlinux2.id
  instance_type   = "t2.micro"
  security_groups = [module.private_sg.security_group_id]
  user_data       = filebase64("scripts/game-bird.sh")

  create_iam_instance_profile = false
  iam_instance_profile_arn    = module.asg_2048.iam_instance_profile_arn

  tags = {
    Environment = "Terraform"
    Name        = "html-games-2"
  }
}

module "asg_pong" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.10.0"

  name = "asg-pong"

  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.private_subnets
  force_delete              = true

  target_group_arns = [module.alb.target_group_arns[3]]

  launch_template_name        = "html-lt-pong"
  launch_template_description = "Pong Launch template for HTML Games"
  update_default_version      = true
  launch_template_version     = "$Latest"

  instance_name   = "pong"
  image_id        = data.aws_ami.amazonlinux2.id
  instance_type   = "t2.micro"
  security_groups = [module.private_sg.security_group_id]
  user_data       = filebase64("scripts/game-pong.sh")

  create_iam_instance_profile = false
  iam_instance_profile_arn    = module.asg_2048.iam_instance_profile_arn

  tags = {
    Environment = "Terraform"
    Name        = "html-games-3"
  }
}

module "asg_tetris" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.10.0"

  name = "asg-tetris"

  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.private_subnets
  force_delete              = true

  target_group_arns = [module.alb.target_group_arns[4]]

  launch_template_name        = "html-lt-tetris"
  launch_template_description = "Tetris Launch template for HTML Games"
  update_default_version      = true
  launch_template_version     = "$Latest"

  instance_name   = "tetris"
  image_id        = data.aws_ami.amazonlinux2.id
  instance_type   = "t2.micro"
  security_groups = [module.private_sg.security_group_id]
  user_data       = filebase64("scripts/game-tetris.sh")

  create_iam_instance_profile = false
  iam_instance_profile_arn    = module.asg_2048.iam_instance_profile_arn

  tags = {
    Environment = "Terraform"
    Name        = "html-games-4"
  }
}
