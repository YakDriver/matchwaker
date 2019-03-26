provider "aws" {
  region = "${var.aws_region}"
}

# AMIs and AMI keys - data structures to represent, no user input considered... yet
locals {
  windows_versions = ["2008", "2012", "2016"]

  ami_name_filters = {
    "${local.windows_versions[0]}" = "Windows_Server-2008-R2_SP1-English-64Bit-Base*"
    "${local.windows_versions[1]}" = "Windows_Server-2012-R2_RTM-English-64Bit-Base*"
    "${local.windows_versions[2]}" = "Windows_Server-2016-English-Full-Base*"
  }

  ami_owners = ["801119661308"]
}

# security and networking ===========================

# Subnet for instance
data "aws_subnet" "matchwaker" {
  id = "${var.subnet_id == "" ? aws_default_subnet.matchwaker.id : var.subnet_id}"
}

# Used to get local ip for security group ingress
data "http" "ip" {
  url = "http://ipv4.icanhazip.com"
}

# used for importing the key pair created using aws cli
resource "aws_key_pair" "auth" {
  key_name   = "${random_id.matchwaker.b64_url}-key"
  public_key = "${tls_private_key.gen_key.public_key_openssh}"
}

resource "tls_private_key" "gen_key" {
  count     = "1"
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "random_string" "password" {
  count            = 1
  length           = 16
  special          = true
  override_special = "()~!@#^*+=|[]:;,?"
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  min_upper        = 2
}

resource "random_id" "matchwaker" {
  byte_length = 5
  prefix      = "${var.name_prefix}-"
}

resource "aws_default_subnet" "matchwaker" {
  availability_zone = "${var.az_to_find_subnet}"
}

# Security group to access the instances over WinRM
resource "aws_security_group" "win_sg" {
  count       = 1
  name        = "${random_id.matchwaker.b64_url}"
  description = "Used for matchwaker"
  vpc_id      = "${data.aws_subnet.matchwaker.vpc_id}"

  tags {
    Name = "${random_id.matchwaker.b64_url}"
  }

  # access from anywhere
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.ip.body)}/32"]
  }

  # access from anywhere
  ingress {
    from_port   = 5985
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.ip.body)}/32"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ec2 instance ===========================
#used just to find the ami id matching criteria, which is then used in provisioning resource
data "aws_ami" "find_ami" {
  count       = 1
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["${local.ami_name_filters[var.windows_version]}"]
  }

  owners = ["801119661308"]
}

# ec2 instance
resource "aws_instance" "matchwaker" {
  count = 1
  ami   = "${data.aws_ami.find_ami.id}"

  associate_public_ip_address = "true"
  iam_instance_profile        = "${var.instance_profile}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${aws_key_pair.auth.id}"
  subnet_id                   = "${var.subnet_id}"
  user_data                   = "<powershell>\n${data.template_file.userdata.rendered}\n</powershell>"
  vpc_security_group_ids      = ["${aws_security_group.win_sg.id}"]

  tags {
    Name = "${random_id.matchwaker.b64_url}"
  }

  timeouts {
    create = "30m"
  }

  connection {
    type     = "winrm"
    user     = "Administrator"
    password = "${random_string.password.result}"
    timeout  = "20m"
  }

  provisioner "file" {
    content     = "${data.template_file.verify_install.rendered}"
    destination = "C:\\scripts\\verify_install.ps1"
  }

  provisioner "remote-exec" {
    inline = [
      "powershell.exe -File C:\\scripts\\verify_install.ps1",
    ]
  }
}

data "template_file" "userdata" {
  count    = 1
  template = "${file("userdata.ps1")}"

  vars {
    adm_pass = "${random_string.password.result}"
    py_ver   = "${var.python_version}"
    git_ver  = "${var.git_version}"
    git_repo = "${var.git_repo}"
    git_ref  = "${var.git_ref}"
    wam_args = "${var.wam_args}"
  }
}

data "template_file" "verify_install" {
  count    = 1
  template = "${file("verify_install.ps1")}"
}
