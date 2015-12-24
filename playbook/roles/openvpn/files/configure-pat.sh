#!/bin/bash

# Configure the instance to run as a Port Address Translator (PAT) to provide
# Internet connectivity to private instances.
#

set -x
echo "Determining the MAC address on eth0"
ETH0_MAC=`/sbin/ifconfig  | /bin/grep eth0 | awk '{print tolower($5)}' | grep '^[0-9a-f]\{2\}\(:[0-9a-f]\{2\}\)\{5\}$'`
if [ $? -ne 0 ] ; then
   echo "Unable to determine MAC address on eth0" | logger -t "ec2"
   exit 1
fi
echo "Found MAC: ${ETH0_MAC} on eth0" | logger -t "ec2"


VPC_CIDR_URI="http://169.254.169.254/latest/meta-data/network/interfaces/macs/${ETH0_MAC}/vpc-ipv4-cidr-block"
echo "Metadata location for vpc ipv4 range: ${VPC_CIDR_URI}" | logger -t "ec2"

VPC_CIDR_RANGE=`curl --retry 3 --retry-delay 0 --silent --fail ${VPC_CIDR_URI}`
if [ $? -ne 0 ] ; then
   echo "Unable to retrive VPC CIDR range from meta-data. Using 0.0.0.0/0 instead. PAT may not function correctly" | logger -t "ec2"
   VPC_CIDR_RANGE="0.0.0.0/0"
else
   echo "Retrived the VPC CIDR range: ${VPC_CIDR_RANGE} from meta-data" |logger -t "ec2"
fi

echo 1 >  /proc/sys/net/ipv4/ip_forward && \
   echo 0 >  /proc/sys/net/ipv4/conf/eth0/send_redirects && \
   /sbin/iptables -t nat -A POSTROUTING -o eth0 -s ${VPC_CIDR_RANGE} -j MASQUERADE

if [ $? -ne 0 ] ; then
   echo "Configuration of PAT failed" | logger -t "ec2"
   exit 0
fi

# additional rules for dropping unwanted traffic.
# rc.local will be run after fail2ban
/sbin/iptables -N blackhole
/sbin/iptables -I INPUT -j blackhole
/sbin/iptables -I FORWARD -j blackhole
/sbin/iptables -I OUTPUT -j blackhole
for ip in $(egrep -v  "^#|^$" /usr/local/etc/blackhole)
do
	/sbin/iptables -A blackhole -s $ip -j DROP
done
/sbin/iptables -A blackhole -j RETURN
/sbin/iptables -N logdrop
/sbin/iptables -A logdrop -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 7
/sbin/iptables -A logdrop -j DROP
/sbin/iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
/sbin/iptables -A INPUT -i lo -j ACCEPT
/sbin/iptables -A INPUT ! -i lo -d 127.0.0.0/8 -j logdrop
/sbin/iptables -A INPUT -p tcp ! --syn -m state --state NEW -j logdrop
/sbin/iptables -A INPUT -i eth0 -p icmp -m limit --limit 3/s -j ACCEPT
/sbin/iptables -A INPUT -i eth0 -p icmp -j DROP
/sbin/iptables -A INPUT -i eth0 -s ${VPC_CIDR_RANGE} -j ACCEPT
for interface in $(ifconfig | awk '/^tun/ {print $1}')
do
	/sbin/iptables -A INPUT -i ${interface} -j ACCEPT
done
/sbin/iptables -A INPUT -i eth0 -p tcp -m tcp --dport 22 -j ACCEPT
/sbin/iptables -A INPUT -i eth0 -p tcp -m tcp --dport 443 -j ACCEPT
/sbin/iptables -A INPUT -i eth0 -p udp -m udp --dport 443 -j ACCEPT
/sbin/iptables -A INPUT -i eth0 -p udp -m udp --dport 1194 -j ACCEPT
/sbin/iptables -A INPUT -j logdrop
/sbin/iptables -A OUTPUT -o eth0 -p icmp -m limit --limit 3/s -j ACCEPT
/sbin/iptables -A OUTPUT -o eth0 -p icmp -j DROP
# create masquerade rules for openvpn tunnels that push our server as
# the default gateway
for config in $(egrep -l '^push "redirect-gateway def1 bypass-dhcp"$' \
  /etc/openvpn/*.conf)
do
        /sbin/iptables -t nat -A POSTROUTING -o eth0 -s \
	  $(awk '/^server / {print $2"/"$3}' ${config}) -j MASQUERADE
done

echo "Configuration of PAT complete" |logger -t "ec2"
exit 0
