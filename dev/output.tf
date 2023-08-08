output "jenkins-server-public-ip" {
  value = module.jenkins-server.jenkins-server-public-ip

}

output "webserver-public-ip" {
  value = module.webserver.webserver-public-ip
}
