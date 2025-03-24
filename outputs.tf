output "nat_instance_public_ips" {
  value = [for instance in data.aws_instance.nat_instance_details : [instance.availability_zone,instance.public_ip]]
  description = "A list of the nat instances public ips"
}

output "eni_rtb_pairs" {
  value = local.eni_rtb_pairs
  description = "A list of ( private_route_tables_ids , associated eni_id ) pairs"
}

output "ami_id" {
  value = local.ami
  description = "The nat instance ami id"
}

output "instance_type" {
  value = var.instance_type
  description = "The nat instance type"
}

output "eni_arns" {
  value = aws_network_interface.NAT_instance_eni.*.arn
  description = "A list of the nat instances eni arns"
}

output "eni_ids" {
  value = aws_network_interface.NAT_instance_eni.*.id
  description = "A list of the nat instances eni ids"
}

output "asg_arns" {
  value = aws_autoscaling_group.NAT_instance_asg.*.arn
  description = "A list of the nat instances asg arns"
}

output "asg_ids" {
  value = aws_autoscaling_group.NAT_instance_asg.*.id
  description = "A list of the nat instances asg ids"
}

output "NAT_security_group_id" {
  value = aws_security_group.NAT_instance_sg.id
  description = "The nat instance security group id"
}

output "NAT_security_group_arn" {
  value = aws_security_group.NAT_instance_sg.arn
  description = "The nat instance security group arn"
}