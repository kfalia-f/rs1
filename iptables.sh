#!/bin/bash
export IPT="iptables"

$IPT -F
$IPT -F -t nat
$IPT -F -t mangle
$IPT -X
$IPT -t nat -X
$IPT -t mangle -X

$IPT -P INPUT DROP
$IPT -P FORWARD DROP
$IPT -P OUTPUT DROP

$IPT -A OUTPUT -o enp0s3 -j ACCEPT
$IPT -A INPUT -p icmp -j ACCEPT
$IPT -A INPUT -i lo -j ACCEPT

$IPT -A INPUT -p all -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
$IPT -A OUTPUT -p all -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
$IPT -A FORWARD -p all -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

$IPT -A INPUT -m conntrack --ctstate INVALID -j DROP
$IPT -A FORWARD -m conntrack --ctstate INVALID -j DROP
$IPT -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
$IPT -A INPUT -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
$IPT -A FORWARD -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
$IPT -A INPUT -i enp0s3 -f -j DROP

$IPT -A INPUT -p tcp -m multiport --dport 25,465,110,995,143,993,80,443,50684 -j ACCEPT
$IPT -A INPUT -p tcp -m conntrack --ctstate NEW -m limit --limit 60/s --limit-burst 20 -j ACCEPT
$IPT -A INPUT -p tcp -m conntrack --ctstate NEW -j DROP
$IPT -A INPUT -i enp0s3 -p udp --dport 53 -j ACCEPT

$IPT -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP
$IPT -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
$IPT -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP
$IPT -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
$IPT -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
$IPT -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
$IPT -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
$IPT -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP
$IPT -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP
$IPT -t mangle -A PREROUTING -p tcp --tcp-flags ACK,FIN FIN -j DROP
$IPT -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP
$IPT -t mangle -A PREROUTING -p tcp --tcp-flags ALL ALL -j DROP
$IPT -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP
$IPT -t mangle -A PREROUTING -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
$IPT -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP
$IPT -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP 
$IPT -t mangle -A PREROUTING -p icmp -j DROP
$IPT -A INPUT -p tcp -m connlimit --connlimit-above 10 -j REJECT --reject-with tcp-reset
$IPT -A INPUT -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j ACCEPT
$IPT -A INPUT -p tcp --tcp-flags RST RST -j DROP

### SSH brute-force protection ### 
$IPT -A INPUT -p tcp --dport 50684 -m conntrack --ctstate NEW -m recent --set
$IPT -A INPUT -p tcp --dport 50484 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 10 -j DROP

### Protection against port scanning ### 
$IPT -N port-scanning
$IPT -A port-scanning -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 2 -j RETURN
$IPT -A port-scanning -j DROP

/sbin/iptables-save > /etc/sysconfig/iptables
