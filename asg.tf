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

module "asg-1" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.10.0"

  name = "2048"

  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.private_subnets
  force_delete              = true

  target_group_arns = [module.alb.target_group_arns[0]]

  launch_template_name        = "html-launch-template1"
  launch_template_description = "Launch template for HTML Games"
  update_default_version      = true
  launch_template_version     = "$Latest"

  instance_name   = "2048" 
  image_id        = data.aws_ami.amazonlinux2.id
  instance_type   = "t2.micro"
  security_groups = [module.private_sg.security_group_id]
  user_data       = filebase64("game-2048.sh")

  create_iam_instance_profile = true
  iam_role_name               = "ssm-iam-profile"
  iam_role_path               = "/ec2/"
  iam_role_description        = "IAM role for SSM Access to EC2"
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

module "asg-2" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.10.0"

  name = "floppybird"

  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.private_subnets
  force_delete              = true

  target_group_arns = [module.alb.target_group_arns[1]]

  #   create_launch_template  = false
  #   launch_template         = module.asg-1.launch_template_name
  #   launch_template_version = "$Latest"

  launch_template_name        = "html-launch-template2"
  launch_template_description = "Launch template for HTML Games"
  update_default_version      = true
  launch_template_version     = "$Latest"

  instance_name   = "floppybird" 
  image_id        = data.aws_ami.amazonlinux2.id
  instance_type   = "t2.micro"
  security_groups = [module.private_sg.security_group_id]
  user_data       = filebase64("game-bird.sh")

  create_iam_instance_profile = false
  iam_instance_profile_arn    = module.asg-1.iam_instance_profile_arn

  tags = {
    Environment = "Terraform"
    Name        = "html-games-2"
  }
}
