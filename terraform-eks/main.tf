
module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "5.1.1"

    name = "crud-vpc"
    cidr = "10.0.0.0/16"

    azs = ["ap-south-1a", "ap-south-1b"]
    piblic_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnets = [10.0.11.0/24", "10.0.12.0/24"]

    enable_nat_gateway = true
    single_nat_gateway = true

    tags = {
        "Terraform" = "true"
        "Environment" = "dev"
    }
}

module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "20.8.4"

    cluster_name = var.cluster_name
    cluster_version = "1.29"
    subnet_ids = module.vpc.private_subnets
    vpc_id = module.vpc.vpc_id


    eks_managed_node_groups = {
        default = {
            instance_types = [var.node_instance_type]
            min_size = [var.min_capacity]
            max_size = [var.max_capacity]
            desired_size = [var.desired_capacity]
        }
    }

    tags = {
        "Environment" = "dev"s
        Terraform" = "true"
    }

}
