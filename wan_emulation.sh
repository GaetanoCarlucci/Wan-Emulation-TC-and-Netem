#!/bin/bash
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#Author: Gaetano Carlucci

tc="sudo /sbin/tc"
modprobe="sudo /sbin/modprobe"
ip="sudo /sbin/ip"

# This function disabled the NIC optimizations that interfere with the experiment
# INPUT PARAMETER
# 1 : Device interface that receives the traffic: example eth0
function disabe_nic_opt()
{
   DEV=$1
   echo "Optimization on $DEV disabled"
   sudo ethtool -K $DEV gro off
   sudo ethtool -K $DEV tso off
   sudo ethtool -K $DEV gso off
}

# This function introduces link capacity constraints on incoming traffic that comes from an IP address
# INPUT PARAMETER
# 1 : IP address of the sender machine: example 192.168.0.10
# 2 : Bottleneck buffer size in KB (1000 byte): example 30 (30KB)
# 3 : Device interface that receives the traffic: example eth0
# 4 : Capacity constraint: example 250 KBps (equivalent to 2Mbps)
function tc_ingress()
{
   SRC=$1
   QUEUE=$2
   DEV=$3
   KBPS=$4 # kilo bytes per seconds
   BRATE=$[$KBPS*8] #BRATE should be in kbps
   MTU=1000
   
   LIMIT=$[$MTU*$QUEUE] #Queue length in bytes
	
	
   echo "TC SHAPER INGRESS ON $HOSTNAME"
   echo "* rate ${BRATE}kbit ($RATE kbyte)"
   echo "* ip src: $SRC"
   echo "* dev $DEV"

   $modprobe ifb
   $ip link set  dev ifb1 up
   $tc qdisc add dev $DEV ingress
	    
   $tc filter add dev $DEV parent ffff: protocol ip u32 match ip src $SRC flowid 1:1 action mirred egress redirect dev ifb1
   $tc qdisc add dev ifb1 root handle 1: tbf rate ${BRATE}kbit minburst $MTU burst $[$MTU*10] limit $LIMIT
}

# This function introduces link capacity constraints on incoming traffic
# INPUT PARAMETER
# 1 : Bottleneck buffer size in KB (1000 byte): example 30 (30KB)
# 2 : Device interface that receives the traffic: example eth0
# 3 : Capacity constraint: example 250 KBps (equivalent to 2Mbps)
function tc_ingress_all()
{
   QUEUE=$1
   DEV=$2
   KBPS=$3 # kilo bytes per seconds
   BRATE=$[$KBPS*8] #BRATE should be in kbps
   MTU=1000
  
   LIMIT=$[$MTU*$QUEUE] #Queue length in bytes
  
  
   echo "TC SHAPER INGRESS ON $HOSTNAME"
   echo "* rate ${BRATE}kbit ($RATE kbyte)"
   echo "* dev $DEV"

   $modprobe ifb
   $ip link set  dev ifb1 up
   $tc qdisc add dev $DEV ingress
      
   $tc filter add dev $DEV parent ffff: protocol ip u32 match u32 0 0 flowid 1:1 action mirred egress redirect dev ifb1
   $tc qdisc add dev ifb1 root handle 1: tbf rate ${BRATE}kbit minburst $MTU burst $[$MTU*10] limit $LIMIT
}

# This function removes the capacity constraint on the incoming traffic
# INPUT PARAMETER
# 1 : Device interface that receives the traffic: example eth0
function tc_del_ingress() {
   DEV=$1
   $tc qdisc del dev $DEV ingress
   $tc qdisc del dev ifb1 root
   $ip link  set dev ifb1 down
   echo "Bandwidth constraint ingress turned off on $DEV"
}

# This function introduces link capacity constraints on outgoing traffic
# INPUT PARAMETER
# 1 : Bottleneck buffer size in KB (1000 byte): example 30 (30KB)
# 2 : Device interface that sends the traffic: example eth0
# 3 : Capacity constraint: example 250 KBps (equivalent to 2Mbps)
function tc_egress() {
   QUEUE=$1
   DEV=$2
   KBPS=$3 # kilo bytes per seconds
   BRATE=$[$KBPS*8] #BRATE should be in kbps
   MTU=1000
   LIMIT=$[$MTU*$QUEUE] #Queue length in bytes
  
   echo "TC SHAPER EGREES ON $HOSTNAME"
   echo "* rate ${BRATE}kbit ($RATE kbyte)"
   echo "* dev $DEV"

   $tc qdisc add dev $DEV root handle 1: tbf rate ${BRATE}kbit minburst $MTU burst $[$MTU*10] limit $LIMIT
}

# This function removes the capacity constraint on the outgoing traffic
# INPUT PARAMETER
# 1 : Device interface that sends the traffic: example eth0
function tc_del_egress() {
   DEV=$1
   $tc qdisc del dev $DEV root
   echo "Bandwidth constraint egress turned off on $DEV"
}
  
# This function introduces propagation delay on the traffic over the specified interface (this cannot be done on the same machine that sets the capacity constraint)
# INPUT PARAMETER
# 1 : Device interface that introduces the delay on the traffic: example eth0
# 2 : Delay we want to set in ms: example 50 ms
function tc_delay() {
   DEV=$1
   DELAY=$2
   echo "tc_delay: dev: $DEV delay: $DELAY ms"
   $tc qdisc add dev $DEV root netem delay ${DELAY}ms
}

# This function removes propagation delay 
# INPUT PARAMETER
# 1 : Device interface that introduces the delay on the traffic: example eth0
function tc_del_delay()
{
   DEV=$1
   $tc qdisc del dev $DEV root
   echo "Delay turned off on $DEV"
}


# This function adds fair queuing policy on incoming traffic 
# This function must be execute after function tc_ingress/tc_ingress_all
function add_sfq_ingress()
{
   $tc qdisc add dev ifb1 parent 1:1 handle 10: sfq perturb 10  
}


# This function adds fair queuing policy on outgoing traffic 
# This function must be execute after function tc_egress
# INPUT PARAMETER
# 1 : Device interface 
function add_sfq_egress()
{
   DEV=$1
   $tc qdisc add dev $DEV parent 1:1 handle 10: sfq perturb 10
}

$@