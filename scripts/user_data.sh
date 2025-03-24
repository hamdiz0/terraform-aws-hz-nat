set -euo pipefail

if [ $USE_SCRIPT == "true" ]; then
  yum install iptables-services -y
  systemctl enable iptables
  systemctl start iptables
# enable IP forwarding
  echo "net.ipv4.ip_forward=1" >> /etc/sysctl.d/custom-ip-forwarding.conf
  sysctl -p /etc/sysctl.d/custom-ip-forwarding.conf
# retrive the primary interface id using EC2 metadata
  TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
  MAC=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/network/interfaces/macs/ | head -1)
  PRIMARY_INTERFACE=$(ip -o link show | grep ${MAC%/} | awk -F': ' '{print $2}')
# configure NAT instance
  /sbin/iptables -t nat -A POSTROUTING -o $PRIMARY_INTERFACE -j MASQUERADE
  /sbin/iptables -F FORWARD
  iptables-save > /etc/sysconfig/iptables
else 
  echo "Skipping NAT instance configuration"
fi