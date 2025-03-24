# hz-NAT

#### A Terraform module to create a basic `NAT_Instance` setup on aws.
##### The module creates a `Network Interface` and an `Auto Scaling Group` based on the specified `Public Subnet` in the inputs.
##### The ASG will spin up a single `NAT Instance` in the specified Public Subnet using a `Launch Template`.
##### The `Launch Template` attaches the `Network Interface` to the instance and uses a `user data` script to configure the `NAT Instance`.
##### The script is based on the official AWS [Create a NAT AMI](https://docs.aws.amazon.com/vpc/latest/userguide/work-with-nat-instances.html#create-nat-ami).
##### This module doesn't use a custom AMI, rather it executes the NAT configuration on launch of the instance using the default `Amazon Linux 2023 AMI` . while the execution doesn't take long, it is preferable to use a custom AMI.

#### Inputs:
- `ami_id`: The ID of the AMI to use for the NAT instance. Default is the Amazon Linux 2023 AMI. (optional)
- `instance_type`: The instance type to use for the NAT instance. Default is `t4g.micro`. (optional)
- `use_ssh`: Whether to allow SSH access to the NAT instance. Default is `false`. (optional)
- `key_name`: The key pair to use for the NAT instance. (optional)
- `use_script`: Whether to use the user data script to configure the NAT instance. Default is `true`. (optional)
- `vpc_id`: The ID of the VPC to create the NAT instance in. (required)
- `map_subnet_rtbs`: A list of pairs where the first element is a public subnet ID and the second element is a list of private route table IDs. (required)

### Outputs:
- `nat_instance_public_ips`: A list of NAT instance public IPs along with their availability zones.
- `eni_rtb_pairs`: A list of pairs where each pair contains a private route table ID and its associated ENI ID.
- `ami_id`: The ID of the AMI used for the NAT instance.
- `instance_type`: The instance type of the NAT instance.
- `eni_arns`: A list of ENI ARNs associated with the NAT instance.
- `eni_ids`: A list of ENI IDs associated with the NAT instance.
- `asg_arns`: A list of ARNs for the Auto Scaling Groups managing NAT instances.
- `asg_ids`: A list of IDs for the Auto Scaling Groups managing NAT instances.
- `NAT_security_group_id`: The security group ID assigned to the NAT instance.
- `NAT_security_group_arn`: The security group ARN assigned to the NAT instance.

### Usage:
#### basic:
```hcl
module "hz-NAT" {
  source        = "hamdiz0/hz-nat/aws"
  instance_type = "t4g.micro"
  vpc_id        = aws_vpc.vpc.id
  map_subnet_rtbs = [
    ([ # ( public subnet id , [private route tables ids] ) 
      public-subnet-id, [private_rtb_1_id, private_rtb_2_id , ...]
    ])
  ]
}   
```
#### cross-az-optimized:
##### The module doesn't have a built in cross az optimization, rather it is up to the user to provide the necessary inputs or modify the network configuration to achieve optimal solution.
##### if cross az data transfer is concern , you may want to deploy multiple NAT instances in different AZs.
##### make sure to create a public subnet in each AZ and provide the private route tables ids associated with subnets on that same AZ.
##### also make sure not to specify a route table multiple times to avoid confilcts.
```hcl
module "hz-NAT" {
  source        = "hamdiz0/hz-nat/aws"
  instance_type = "t4g.micro"
  vpc_id        = aws_vpc.vpc.id
  map_subnet_rtbs = [
    ([ # ( public subnet id , [private route tables ids] )
      public-subnet-id-az1, [private_rtb_1_id-az1, private_rtb_2_az2]
    ]),
    ([
      public-subnet-id-az2, [private_rtb_3_id-az2]
    ]),
    ([
      public-subnet-id-az3, [private_rtb_4_id-az3]
    ])
  ]
}   
```

### This module is pretty basic, do not hesitate to seggest improvments and contribute.