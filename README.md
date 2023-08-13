# Deploy Personal portfolio webpage using Jenkins and Github webhook on Apache and AWS infrastructure provisioning using terraform

In the ever-evolving landscape of web development, the ability to efficiently deploy and manage a webpage is crucial for ensuring a seamless online experience. Leveraging automation tools and integrations can significantly enhance this process. One such powerful combination involves utilizing Jenkins, a popular automation server, in conjunction with GitHub webhooks, to effortlessly deploy web content. When paired with an Apache web server, this dynamic trio forms a robust ecosystem for managing and serving webpages. In this introduction, we embark on a journey to explore how to deploy a webpage using the collaborative prowess of Jenkins and GitHub webhooks, all while harnessing the reliable capabilities of an Apache web server. By following this guide, you'll be well on your way to optimizing your deployment workflow and delivering web content with precision and ease.

![App Screenshot](images/image1.png)

# Infrastructure Provisioning Using terraform 

Here we first provision Jenkins server in aws instances where jenkins is installed and webserver instance where apache installed in aws EC2 instances. 


## Terraform

### Pre-requisite:

- Please make sure you create a provider.tf file

```javascript
provider "aws" {
  region                  = var.region
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "default"
}
```

The ‘credentials file’ will contain 'aws_access_key_id' and 'aws_secret_access_key'.

- Keep SSH keys handy for jenkins server apache machines.

Here is a nice article [link](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys-2) highlighting how to create it or else create them beforehand on AWS console and reference it in the code.

![App Screenshot](images/flow-tree.png)

For simplicity purpose, we will be using Linux machine for creating Jenkins server and Linux webserver. It’s now time to start using terraform for creating the machines.

#### VPC

The module VPC creates virtual private cloud.

#### Security

The module contains terraform code to create instance level traffic inflow and outflow rules.

#### keypair

The module keypair contains terraform code to create ssh keypair on AWS console.

#### Jenkins-Server

This module contains terraform code to create Jenkins-server with jenkins.

#### Webserver

This module contains terraform code to create webserver with apache.

### Run the terraform code

To deploy master and slave aws instances, run terraform command under the directory **/dev** because all modules are invoked and deployed from this folder.

```bash
terraform init
```

```bash
terraform validate
```

```bash
terraform apply --auto-approve
```

## Script for jenkins server and Apache webserver

#### Install jenkins on jenkin-server node

```bash

#!/bin/bash
#################################
# Author: Santosh
# Date: 8th-August-2023
# version 1
# This code install jenkins in the ubuntu instances
##################################

sudo apt update -y
sudo apt install openjdk-17-jre -y
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
 /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
 https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
 /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins

```

(This script is on jenkins-server as data.sh and renders on EC2 instance when terraform deploy via command.)

##### Access URL 
```bash
http://<public IP of Jenkins server>:8080
```
We wiil be asked to enter default admin password like below:
![App Screenshot](images/password.png)

In order to access the default admin password we need to login to the jenkins server and run the command

```bash
sudo cat /var/lib/jenkins/secrets/intialAdminPassword
```

and copy & paste in the windows.

On next screen you can see its asking to install the suggested plugins -
![App Screenshot](images/plugins_default.png)
On the next screen you will be prompted to create jenkins user and finally we will get default Jenkins Dashboard:
![App Screenshot](images/jenkins_ready.png)

#### Install Apache on webserver node
```bash
#!/bin/bash
#################################
# Author: Santosh
# Date: 8th-August-2023
# version 1
# This code install Apache in the ubuntu instances 
##################################


sudo apt update -y
sudo apt install apache2 -y
sudo systemctl status apache2

```
##### Access URL 
```bash
http://<public IP of apache webserver>
```
#### Create ssh keys keypair by the modules keypair in the terraform.
This keypair modules create public key and private key pair at the time of instance booting and private is key downloaded to the user browser whereas public key is saved to the instances under /.ssh/authorized_keys.

```javascript
//Create a key with RSA algorithm with 4096 rsa bits
resource "tls_private_key" "private_key" {
  algorithm = var.keypair_algorithm
  rsa_bits  = var.rsa_bit
}

//create a key pair using above private key
resource "aws_key_pair" "keypair" {
  key_name   = var.keypair_name
  public_key = tls_private_key.private_key.public_key_openssh
  depends_on = [tls_private_key.private_key]
}

//saving the private key at the specific location
resource "local_file" "save-key" {
  content = tls_private_key.private_key.private_key_pem
  //path.module is the module that access current working directory
  filename = "${path.module}/${var.keypair_name}.pem"
  // changes the file permission to read-only mode
  file_permission = "0400"
  depends_on      = [tls_private_key.private_key]
}

```
(Here ssh keypair is created of both jenkins server instance and apache webserver instances and downloaded in the modules keypair and changes to read only permission on the keypair for security reason.)
```bash
ssh -i <kepair-name.pem> <username>@<public-ip-address>
```

You will need to create a public/private key as the Jenkins user on your Jenkins server, then copy the public key to the user you want to do the deployment with on your target server. In AWS when we were create infrastructure of Jenkins server and apache server, the keypair is generated which private key as .pem extension. and its public key is stored in in /.ssh/authorized_keys. Therefore we ssh to the machine with private key to the servers, they accept the communication. 

Since private key is downloaed we need to copy the private key into the jenkins server. The following command is used to
 ```bash
       scp -i <privatekey.pem> <downloaded-private-key> <username>@<public-ip-address>:<path-of-jenkins-directory>
```
```bash
      scp -i keypair-cicd.pem keypair-cicd.pem ubuntu@52.15.193.9:/home/ubuntu/
      keypair-cicd.pem                                 100% 3243    23.3KB/s   00:00 
```
#### Note: Jenkins servers also has its own user and group known as Jenkins. Jenkins stores its file under /var/lib/jenkins/. Therefore, private key of webserver should be store in the path /var/lib/jenkins/ because when pipeline is triggered, jenkins server copies the website contents into the jenkins workspace which are to be deployed in the apache webserver in /var/www/html/ . 

![App Screenshot](images/changing_owner.png)

In order to allow ssh between jenkins server and apache webserver, the private key needs to be stored under jenkins group and user. Therefore following command is copies private key from ubuntu user to location to /var/lib/jenkins/.  
```bash
sudo cp keypair-cicd.pem /var/lib/jenkins/

```


#### Then for deploying the website, we use Publish over ssh plugins.
steps
- Manage plugins
- Plugins
- Choose available plugins
- Search Publish over ssh
- Select install

Again to define system server
steps
- Manage plugins
- systems
 
![App Screenshot](images/publish-over-ssh.png)
![App Screenshot](images/ssh-server.png)

#### Create the job
steps 
- Click New item
- Type name of the item 
- choose freestyle project
- Click Ok
- Select github project and paste urls of repository
- Select git 
- Paste xxxxxx.git from github
- Select github hook trigger from GITScm pooling for webhook
- Select build steps 
- Select send files and execute command over ssh

![App Screenshot](images/ssh-server-publisher.png)

# For CI/CD we user Web-hook for automatic actions
steps
- Browse github repository
- Click at settings
- Click at webhook

![App Screenshot](images/webhook.png)

# Apache Webserver
The folder /var/www/html/ has a default user as root. Therefore, it is supposed to be changed into normal user  and in our case, it is ubuntu.
![App Screenshot](images/website.png)



# Build is triggered.
![App Screenshot](images/final-result.png)

# Final Result
![App Screenshot](images/output.png)


