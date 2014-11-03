#! /bin/bash

# 把 filter 表的 3 个链默认策略暂时修改为 ACCEPT
for i in INPUT FORWARD OUTPUT;do
    iptables -P $i ACCEPT
done

# 清空 3 个表的所有规则并删除所有自定义链
for i in filter nat mangle;do
    iptables -t $i -F
    iptables -t $i -X
done

# 因为做网关，所以做一些处理
modprobe ip_nat_ftp
echo 1 > /proc/sys/net/ipv4/ip_forward

# 设置 INPUT 链，本机自己只允许 ssh 进入，允许向外访问的回包
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -P INPUT DROP

# 只允许内网用户访问 WEB 页面
iptables -A FORWARD -i eth1 -o ppp0 -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -i eth1 -o ppp0 -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -P FORWARD DROP

# 只允许本机 telnet 到外面
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 23 -j ACCEPT
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT DROP

# 做 NAT，带动内网用户上网
iptables -t nat -A POSTROUTING -s 172.17.39.0/24 -o ppp0 -j MASQUERADE