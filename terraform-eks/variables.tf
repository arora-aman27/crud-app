variable "aws_region" {
    description = "AWS region"
    type = string
    default = "ap-south-1"
}

variable "cluster_name" {
    description = "EKS Cluster name"
    type = string
    default = "crud-eks-cluster"
}

variable "node_instance_type" {
    description = "Instance type for worker nodes"
    type = string
    default = "t3.medium"
}

variable "desired_capacity" {
    default = 2
}

variable "max_capacity" {
    default = 3
}

variable "min_capacity" {
    default = 1
}