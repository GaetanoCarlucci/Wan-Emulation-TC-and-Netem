[![Build Status](https://travis-ci.org/webrtc/apprtc.svg?branch=master)](https://travis-ci.org/webrtc/apprtc)

# Wan Emulation with TC and NetEm

## Introduction

This tool allows to emulate a WAN link through the iproute2 package and the NetEm
Linux module. With tc “traffic control” it is possible to set the queuing discipline,
limit the link capacity and much more. The NetEm linux module,
can be employed to set the propagation delay.

##Examples

###Disabling the NIC optimizations 
That NIC optimization parameters may interfere with the experiment. It is RECOMMENDED to disable those.<br />
INPUT PARAMETER__
1 : Device interface that receives the traffic: example eth0__

```
sudo apt-get install ethtool
./wan_emulation.sh disabe_nic_opt "eth0"
```

###Set capacity constraint on incoming traffic
This command introduces link capacity constraints on incoming traffic that comes from a specified IP.__
INPUT PARAMETER__
1 : IP address of the sender machine: example 192.168.0.10__
2 : Bottleneck buffer size in number of packets (1500 byte per packet): example 30__
3 : Device interface that receives the traffic: example eth0__
4 : Capacity contraint: example 250 KBps (equivalent to 2Mbps)__

```
./wan_emulation.sh tc_ingress 192.168.0.10 30 eth0 125
```

###Set sfq policy on the incoming traffic
This commands adds fair queuing policy on incoming traffic and must be execute after function tc_ingress.__
```
./wan_emulation.sh add_sfq_ingress
```

###Set propagation delay 
This command set propagation delay on the traffic over the specified interface.__
**This command cannot be executed on the same machine that sets the capacity constraint**__
INPUT PARAMETER__
1 : Device interface that introduces the delay on the traffic: example eth0__
2 : Delay we want to set in ms: example 50 ms__

```
./wan_emulation.sh tc_delay eth0 50
```

###Remove propagation delay 
This command removed the propagation delay on the traffic over the specified interface.__
INPUT PARAMETER__
1 : Device interface that introduces the delay on the traffic: example eth0__

```
./wan_emulation.sh tc_del_delay eth0 
```

##References
http://www.linuxfoundation.org/collaborate/workgroups/networking/netem#Emulating_wide_area_network_delays