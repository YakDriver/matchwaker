output "ami_id" {
  description = "ID of AMI used to launch instance"
  value       = "${data.aws_ami.find_ami.id}"
}

output "ami_name" {
  description = "Name of AMI used to launch instance"
  value       = "${data.aws_ami.find_ami.name}"
}

output "win_pass" {
  description = "Randomly generated password assigned to Admin account"
  value       = "${random_string.password.result}"
  sensitive   = true
}

output "public_dns" {
  description = "Public DNS name assigned to the instance"
  value       = "${aws_instance.matchwaker.public_dns}"
}

output "public_ip" {
  description = "Public IP assigned to the instance"
  value       = "${aws_instance.matchwaker.public_ip}"
}

output "instance_id" {
  description = "ID of EC2 instance"
  value       = "${aws_instance.matchwaker.id}"
}

output "key_pair_name" {
  description = "Name of the key pair generated for instance"
  value       = "${aws_key_pair.auth.id}"
}

output "security_group_id" {
  description = "ID of the security group for the instance"
  value       = "${aws_security_group.win_sg.id}"
}

output "vpc_security_group_id" {
  description = "ID of the VPC security group"
  value       = ["${aws_instance.matchwaker.vpc_security_group_ids}"]
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = "${aws_instance.matchwaker.subnet_id}"
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = "${aws_security_group.win_sg.vpc_id}"
}

output "aws_region" {
  description = "Region used by the module"
  value       = "${var.aws_region}"
}
