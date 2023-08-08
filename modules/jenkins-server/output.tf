output "jenkins-server-public-ip" {
  value = aws_instance.jenkins-server.public_ip
}
