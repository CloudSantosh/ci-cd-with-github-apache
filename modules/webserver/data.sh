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
