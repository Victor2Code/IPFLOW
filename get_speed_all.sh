#!/bin/bash

function get_ipflow(){
outer=`iptables -n -v -L FORWARD -x | grep "IPFLOW" | grep "192.168.115.0/24[[:space:]]*0.0.0.0/0" | awk '{print $2}'`
inner=`iptables -n -v -L FORWARD -x | grep "IPFLOW" | grep "0.0.0.0/0[[:space:]]*192.168.115.0/24" | awk '{print $2}'`
echo "("
echo ['inner']=$inner
echo ['outer']=$outer
echo ")"
}

declare -A dic1=`get_ipflow`
sleep 2
declare -A dic2=`get_ipflow`

printf "%-15s %-20s %-20s %-20s %-20s\n" IP DL-Speed UL-Speed DL-Volume UL-Volume
inner_speed=`echo "scale=2;(${dic2['inner']}-${dic1['inner']})/2048" | bc`
outer_speed=`echo "scale=2;(${dic2['outer']}-${dic1['outer']})/2048" | bc`
printf "%-15s %-20s %-20s %-20s %-20s\n" ALL ${inner_speed}KBps ${outer_speed}KBps ${dic2['inner']}Bytes ${dic2['outer']}Bytes
