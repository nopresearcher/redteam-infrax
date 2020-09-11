# Overview
This gives you a Windows Server 2019, Kali (latest) and Ubunutu 20.04 (disabled) on AWS. It is configurable to only deploy what boxes you want.  After deployment it installs a number of tools and does some configuration.  The installs happen concurrently which speeds things up, however this can still take 20 minutes.  Total cost of running one windows and one linux host with storage for the month is ~$26, with the free tier discount ~$3.

# Setup
Run all the commands from the root of the repo
## if on MacOS - prevents error when running ansible with winrm
```
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
```
## configure AWS credentials
```
export AWS_ACCESS_KEY_ID=<ID>
export AWS_SECRET_ACCESS_KEY=<KEY>
```
## terraform configuration
### set AWS region if necessary
```
vim providers.tf 
```
### generate keys
```
ssh-keygen -m PEM -f key.pem
ssh-keygen -y -f key.pem > key.pem.pub
```
### set passwords & configure
```
vim modules/attack/variables.tf
```
# terraform 
```
terraform init
terraform plan
terraform apply
terraform show
terraform destroy
```

# connect
Windows - RDP with Administrator and password

Kali - SSH with key; set password for kali; then RDP

Ubuntu - SSH with key

# troubleshooting
## Failed ansible - typically due to timeouts
```
cd modules/attack/ansible
ansible-playbook -i hosts.win playbooks/windows.yml
ansible-playbook -i hosts.kali playbooks/kali.yml
```

# AWS marketplace agreements
## Kali Linux AMI - subscribe
https://aws.amazon.com/marketplace/pp/Kali-Linux-Kali-Linux/B01M26MMTT

## Windows Server 2019 - subscribe
https://aws.amazon.com/marketplace/pp/B07QZ4XZ8F?qid=1599672834735&sr=0-1&ref_=brs_res_product_title

## Ubuntu 20.04 - subscribe
https://aws.amazon.com/marketplace/pp/B087QQNGF1?qid=1599673016044&sr=0-1&ref_=srh_res_product_title

# Warnings
Al windows winrm connections are in the clear, need to add certificates.  WinRM access locked down to public IP of host executing terraform.

# TODO
windows - winRM certificate connection for ansible
create outputs with connection information.
windows - nmap install hangs

https://dev.to/aakatev/deploy-ec2-instance-in-minutes-with-terraform-ip2




https://github.com/dirtyfilthy/siem-from-scratch/blob/master/Vagrantfile
https://www.jigsawcode.com/packer-windows-server-2016-ami/
https://sethsec.blogspot.com/2017/05/pentest-home-lab-0x1-building-your-ad.html