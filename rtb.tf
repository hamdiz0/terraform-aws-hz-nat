# create a list of pairs { [(rtb-1 ,rtb-2) , eni-1] , [(rtb-2) , eni-2] }
locals {
  eni_rtb_pairs = flatten([
    for index, data in var.map_subnet_rtbs : [
      for rt_id in data[1] : {
        rt_id  = rt_id
        eni_id = aws_network_interface.NAT_instance_eni[index].id
      }
    ]
  ])
}

# create a route for each routable using the the paired eni
resource "aws_route" "nat_route" {
  count                  = length(local.eni_rtb_pairs)
  route_table_id         = local.eni_rtb_pairs[count.index].rt_id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = local.eni_rtb_pairs[count.index].eni_id
}