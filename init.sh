#!/bin/bash
# Install terraform
sudo apt-get update -y >> /tmp/user_data.log
sudo apt-get install git -y >> /tmp/user_data.log
sudo apt-get install unzip -y >> /tmp/user_data.log
wget https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_linux_amd64.zip >> /tmp/user_data.log
unzip terraform_0.11.10_linux_amd64.zip >> /tmp/user_data.log
sudo mv terraform /usr/local/bin/ >> /tmp/user_data.log
terraform --version >> /tmp/user_data.log
sudo apt-get install awscli >> /tmp/user_data.log