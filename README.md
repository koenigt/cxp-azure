# cxp-terraform
This project is a sample project to set up a reference like https://d2lxv3e7d7f0dt.cloudfront.net/azure/index.htmlusing terraform


## Assignment 54: Build a reference network on Azure with Terraform using recommended naming conventions for Azure resources
(all Teams)
* Create 1 Resource Group per team, assign all further resources to this resource group
* Create 1 VNet 
* Create 5 Subnets (bastion, application gateway, web, app, data)
* Create 1 default Network Security Group and attach it to the web, app and data subnet (no extra rules required, default rules will do!)
* Create 1 NAT Gateway and attach it to the web, app and data subnet
* Instantiate the Bastion Service and attach it to the bastion subnet
* Add 1 VM (Ubuntu, private IP only) to your web subnet and make sure you can access it using the Bastion Service
##Assignment 55: Add managed groups of VMs to your reference network with Terraform
(all Teams)
* Create 1 DNS zone for DNS records pointing to resources in your network
(naming convention for DNS domain is ${​​​teamName}​​​​​​​​​​.azure.msgoat.eu) and link this DNS zone to the DNS zone azure.msgoat.eu.
* Create 1 Virtual Machine Scale Set with 3 VMs representing web servers based on NGinX
* Create 1 Application Gateway in front of the webservers routing HTTP on port 80 traffic to the web servers
* Create 1 DNS A Record to the DNS zone pointing to the Application Gateway in front of the web servers (web.${​​​​​​​​​​​teamName}​​​​​​​​​​​​​​​​​​.azure.msgoat.eu)
* Make sure you can access your web servers through the Application Gateway using the DNS name
## Assignment 56 (optional): Add support of HTTPS traffic terminating SSL/TLS at the Application Gateway
(all Teams)
* Create 1 Key Vault
* Create 1 Key Vault SSL/TLS certificate for DNS names
(${​​​​​​​​​​​​​​​​​​teamName}​​​​​​​​​​​​​​​​​​.azure.msgoat.eu, *.${​​​​​​​​​​​​​​​​​​teamName}​​​​​​​​​​​​​​​​​​.azure.msgoat.eu)
* Add 1 HTTPS listener to your Application Gateway accepting HTTPS traffic on port 443 using the previously created SSL certificate
* Add 1 Rule to your Application Gateway redirecting all HTTP traffic to HTTPS
* Make sure you can access your web servers using HTTPS

## important commands:
```
terraform plan
terraform apply
terraform destroy
```