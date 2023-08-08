output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_az_id" {
  value = aws_subnet.public_subnet_az.id

}

output "internet_gateway_id" {
  value = aws_internet_gateway.internet_gateway.id
}

output "project_name" {
  value = var.project_name

}

output "region" {
  value = var.region
}
