#!/bin/bash
#get dns server info https://public-dns.info
#DNS_IP=84.200.70.40
#DNS_IP=113.190.42.214
#DNS_IP=125.234.102.149
#DNS_IP=123.30.175.83
#DNS_IP=112.78.1.3
#DNS_IP=202.58.198.138
#DNS_IP=119.110.122.198
#DNS_IP=131.221.80.20
#DNS_IP=202.55.30.121
#DNS_IP=202.55.11.100
#DNS_IP=8.26.56.26

ip_arr=('113.190.42.214' '125.234.102.149' '112.78.1.3' '202.58.198.138' '202.46.115.49' '1.9.204.101')
min_time=10000.00
echo_time=10000.00
min_ip=""

for DNS_IP in ${ip_arr[@]};do
   echo_time=$(ping -c1 -W2 $DNS_IP | grep ttl | awk {'print $7'} |awk -F= {'print $2'})
   if [ -z $echo_time ]
   then
      echo_time=10000.00
   fi
   if [ `echo "$echo_time<$min_time"|bc` -ne 0 ]
   then
      min_time=$echo_time
      min_ip=$DNS_IP
   fi
done
IP_TTL=$(ping -c1 $min_ip | grep ttl | awk {'print $6'} |awk -F= {'print $2'})
echo "get fast dns is $min_ip time is $min_time ms"
echo "get TTL is $IP_TTL"
echo "nameserver $min_ip" > /etc/resolv.conf
iptables -F
iptables -A INPUT -p udp --sport 53 -m ttl --ttl-eq $IP_TTL -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j DROP
