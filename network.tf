module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.0.0/24", "10.0.1.0/24"]
  public_subnets  = ["10.0.2.0/24", "10.0.3.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  vpc_tags = {
    Name = "html-vpc"
  }

  nat_gateway_tags = {
    Name = "nat"
  }

  nat_eip_tags = {
    Name = "nat-iep"
  }

  private_route_table_tags = {
    Name = "private-route"
  }

  public_route_table_tags = {
    Name = "public-route"
  }

  private_subnet_tags = {
    Name = "private-subnet"
  }

  public_subnet_tags = {
    Name = "public-subnet"
  }
}
