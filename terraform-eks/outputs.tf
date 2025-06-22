output "cluster_name" {
    value = module.eks.cluser_name
}

output "kubeconfig" {
    value = module.eks.kubeconfig
    sensitive = true
}

output "cluster_endpoint" {
    value = module.eks.cluster_endpoint
}


