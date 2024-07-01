
# Output the cluster name
output "cluster_name" {
  value = aws_eks_cluster.main.name
}

# Output the cluster endpoint
output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}


output "vpc_id" {
  value = aws_vpc.main.id
}
