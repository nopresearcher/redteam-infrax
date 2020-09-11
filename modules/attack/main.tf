data "http" "my_public_ip" {
  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  ifconfig_co_json = jsondecode(data.http.my_public_ip.body)
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_key_pair" "attack" {
  key_name   = "attack"
  public_key = file(var.path_to_public_key)
}

resource "aws_security_group" "linux" {
  name        = "linux-security-group"
  description = "Allow everything"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform"
  }
}

resource "aws_security_group" "windows" {
  name        = "windows-security-group"
  description = "Allow only RDP and WinRM from my IP and some rando ports"

  ingress {
    description = "Allow some rando ports in from anywhere"
    from_port   = 55000
    to_port     = 60000
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "RDP access from my IP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["${local.ifconfig_co_json.ip}/32"]
  }

  ingress {
    description = "WinRM access from my IP"
    from_port   = 5985
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = ["${local.ifconfig_co_json.ip}/32"]
  }

  egress {
    description = "Allow any outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform"
  }
}


resource "aws_instance" "ubuntu" {
  count         = var.enable_ubuntu ? 1: 0
  key_name      = aws_key_pair.attack.key_name
  ami           = "ami-03c69f0428e980939"
  instance_type = "t2.micro"

  tags = {
    Name = "Ubuntu"
  }

  vpc_security_group_ids = [
    aws_security_group.linux.id
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.path_to_private_key)
    host        = self.public_ip
  }

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_type = "gp2"
    volume_size = 30
  }
}

#resource "aws_eip" "ubuntu" {
#  vpc      = true
#  instance = aws_instance.ubuntu.id
#}

resource "aws_instance" "kali" {
  count         = var.enable_kali ? 1: 0
  key_name      = aws_key_pair.attack.key_name
  ami           = "ami-08c8387e171a3d095"
  instance_type = "t2.micro"

  tags = {
    Name = "Kali"
  }

  vpc_security_group_ids = [
    aws_security_group.linux.id
  ]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.path_to_private_key)
    host        = self.public_ip
  }

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_type = "gp2"
    volume_size = 30
  }

 provisioner "local-exec" {
    working_dir = "modules/attack/ansible"
    command = "sleep 90;cp hosts.kali.default hosts.kali; sed -i '' 's/PUBLICIP/${aws_instance.kali[count.index].public_ip}/g' hosts.kali;ansible-playbook -i hosts.kali playbooks/kali.yml"
  }

}

 
resource "aws_instance" "windows" {
  count         = var.enable_windows ? 1: 0
  key_name      = aws_key_pair.attack.key_name
  ami           = var.windows_ami
  instance_type = "t2.micro"
  get_password_data      =   "true"
  vpc_security_group_ids = [ 
    aws_security_group.windows.id 
  ]
 
  tags = {
    Name = "Windows"
  }

  user_data = <<EOF
<script>
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config @{MaxTimeoutms="1800000"}
</script>
<powershell>
$admin = [adsi]("WinNT://./${var.win_username}, user")
$admin.PSBase.Invoke("SetPassword", "${var.win_password}")
Invoke-Expression ((New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1'))
</powershell>
EOF

 provisioner "local-exec" {
    working_dir = "modules/attack/ansible"
    command = "sleep 120;cp hosts.win.default hosts.win; sed -i '' 's/PUBLICIP/${aws_instance.windows[count.index].public_ip}/g' hosts.win;sed -i '' 's/WINDOWSPASSWORD/${var.win_password}/g' hosts.win;ansible-playbook -i hosts.win playbooks/windows.yml"
  }
}