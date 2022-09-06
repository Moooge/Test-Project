terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.27.0"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = 
  secret_key = 
}

resource "aws_security_group" "node_group_sg" {
  name_prefix = "node_group_sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]

  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name                 = "vpc-project"
  cidr                 = "10.0.0.0/16"
  azs                  = ["eu-west-2a" , "eu-west-2b" , "eu-west-2c"]
  private_subnets      = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  public_subnets       = ["10.0.40.0/24", "10.0.50.0/24", "10.0.60.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }

}

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "18.28.0"
  cluster_name                    = var.cluster_name
  subnet_ids                      = module.vpc.private_subnets
  cluster_timeouts                = var.cluster_timeouts
  cluster_endpoint_private_access = true
  vpc_id                          = module.vpc.vpc_id

  eks_managed_node_group_defaults = {
    disk_size      = 50
    instance_types = ["t2.micro"]
  }

  eks_managed_node_groups = {
    Kubenodes = {
      min_size     = 1
      max_size     = 4
      desired_size = 3

      instance_types = ["t2.micro"]
    }
  }
}
