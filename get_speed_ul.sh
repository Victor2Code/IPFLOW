#!/bin/bash

# modify ip list in ips.txt file before execution

if [ -f temp.txt ];then
rm temp.txt
fi
if [ -f result.txt ];then
rm result.txt
fi

# define a function to retrieve outbound and inbound traffic volume
# IPFLOW is the iptables chain for SG LAN
function get_flow(){
echo "("
while read ip;
do
outer=`iptables -n -v -L IPFLOW -x | grep "$ip[[:space:]]" | grep "$ip[[:space:]]*0.0.0.0/0" | awk '{print $2}'`
inner=`iptables -n -v -L IPFLOW -x | grep "$ip[[:space:]]" | grep "0.0.0.0/0[[:space:]]*$ip" | awk '{print $2}'`
echo [$ip'_inner']=$inner
echo [$ip'_outer']=$outer
done<ips.txt
echo ")"
}

declare -A dic1=`get_flow`
sleep 2
declare -A dic2=`get_flow`

while read ip
do
	key1=$ip'_inner'
	key2=$ip'_outer'
	inner_speed=`echo "scale=2;(${dic2[$key1]}-${dic1[$key1]})/2048" | bc`
	outer_speed=`echo "scale=2;(${dic2[$key2]}-${dic1[$key2]})/2048" | bc`
	printf "%-15s %-20s %-20s %-20s %-20s\n" $ip ${inner_speed}KBps ${outer_speed}KBps ${dic2[$key1]}Bytes ${dic2[$key2]}Bytes >> temp.txt
done<ips.txt

sort -k 3nr temp.txt > result.txt
sed -i '1i\IP		DL-Speed	     UL-Speed		  DL-Volume	       UL-Volume' result.txt

cat result.txt
