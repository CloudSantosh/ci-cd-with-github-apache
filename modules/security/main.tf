
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#  create security group for Jenkins-master and jenkins-slave-nodes
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "security_group_port_8080" {
  name        = "Security group port 8080"
  description = "Enable custom tcp 8080 access"
  vpc_id      = var.vpc_id

  ingress {
    description = "Custome tcp 8080 access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-Security-group-port-8080"
  }
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#  create security group with port 22 i.e. ssh
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "security_group_port_22" {
  name        = "Security group for port 22"
  description = "Enable ssh "
  vpc_id      = var.vpc_id

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    description = "outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-Security-group-port-22"
  }
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#  create security group with port 80 i.e. http
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "security_group_port_80" {
  name        = "Security group for port 80"
  description = "Enable http "
  vpc_id      = var.vpc_id

  ingress {
    description = "http access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    description = "outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-Security-group-port-80"
  }
}
