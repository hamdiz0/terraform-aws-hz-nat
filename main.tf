# default the ami to Amazon Linux 2023  
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }
}

locals { # coalesce : assign the first non null value in a list of attributes
  ami = coalesce(var.ami_id, data.aws_ami.amazon_linux_2023.id)
}

data "aws_subnet" "subnet" {
  count = length(var.map_subnet_rtbs)
  id    = var.map_subnet_rtbs[count.index][0]
}

resource "aws_network_interface" "NAT_instance_eni" {
  count           = length(var.map_subnet_rtbs)
  subnet_id       = data.aws_subnet.subnet[count.index].id
  security_groups = [aws_security_group.NAT_instance_sg.id]
  source_dest_check = false
  tags = {
    Name = "NAT_eni_${data.aws_subnet.subnet[count.index].availability_zone}"
  }
}

resource "aws_launch_template" "NAT_instance_template" {
  count         = length(var.map_subnet_rtbs)
  name_prefix   = "NAT_instance_launch_template"
  key_name = var.use_ssh ? var.key_name : null
  image_id      = local.ami
  instance_type = var.instance_type
  user_data = base64encode(<<-EOF
      #!/bin/bash
      USE_SCRIPT=${var.use_script}
      ${file("${path.module}/scripts/user_data.sh")}
    EOF
  )

  network_interfaces {
    delete_on_termination       = false
    network_interface_id        = aws_network_interface.NAT_instance_eni[count.index].id
    device_index                = 0
  }
}

# create an auto scaling group
resource "aws_autoscaling_group" "NAT_instance_asg" {
  count                     = length(var.map_subnet_rtbs)
  name                      = "NAT_asg_${data.aws_subnet.subnet[count.index].availability_zone}"
  max_size                  = 1
  min_size                  = 1
  desired_capacity          = 1
  health_check_type         = "EC2"
  health_check_grace_period = 0
  default_cooldown          = 0
  availability_zones        = [data.aws_subnet.subnet[count.index].availability_zone]
  launch_template {
    id      = aws_launch_template.NAT_instance_template[count.index].id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "NAT_instance_${data.aws_subnet.subnet[count.index].availability_zone}"
    propagate_at_launch = true
  }
}

# retrieve the NAT instances details
data "aws_instances" "nat_instances" {
  filter {
    name   = "tag:Name"
    values = ["NAT_instance_*"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }

  depends_on = [aws_autoscaling_group.NAT_instance_asg]
}

data "aws_instance" "nat_instance_details" {
  count = length(var.map_subnet_rtbs)
  instance_id = data.aws_instances.nat_instances.ids[count.index]
}