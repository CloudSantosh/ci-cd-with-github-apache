output "webserver-public-ip" {
  value = aws_instance.webserver.public_ip
}
