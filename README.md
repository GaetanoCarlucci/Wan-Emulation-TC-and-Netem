[![Build Status](https://travis-ci.org/webrtc/apprtc.svg?branch=master)](https://travis-ci.org/webrtc/apprtc)

# Wan Emulation with TC and NetEm

## Introduction

This tool allows to emulate a WAN link through the iproute2 package and the NetEm
Linux module. With tc “traffic control” is possible to set the queuing discipline,
limit the link capacity and much more. The NetEm linux module
can be employed to set the propagation delay.

##Examples

###Disabling the NIC optimizations 
That NIC optimization parameters may interfere with the experiment. It is RECOMMENDED to disable these optimization.<br />
 **INPUT PARAMETERS** <br />
-  Device interface that receives the traffic: *example eth0*

```
sudo apt-get install ethtool
./wan_emulation.sh disabe_nic_opt "eth0"
```

###Set capacity constraint on incoming traffic
This command introduces link capacity constraints on incoming traffic that comes from a specified IP.<br />
**INPUT PARAMETERS**<br />
-  IP address of the sender machine: *example 192.168.0.10*<br />
-  Bottleneck buffer size in KB (1000 byte): *example 30 (30KB)*<br />
-  Device interface that receives the traffic: *example eth0*<br />
-  Capacity contraint: *example 125 KBps (equivalent to 1Mbps)*<br />

```
./wan_emulation.sh tc_ingress 192.168.0.10 30 eth0 125
```

###Set sfq policy on the incoming traffic
This command adds fair queuing policy on incoming traffic and must be executed after function tc_ingress.<br />
```
./wan_emulation.sh add_sfq_ingress
```

###Set propagation delay 
This command sets propagation delay on the traffic over the specified interface.<br />
**NB.:** *This command cannot be executed on the same machine that sets the capacity constraint*<br />
**INPUT PARAMETERS**<br />
- Device interface that introduces the delay on the traffic: *example eth0*<br />
- Delay we want to set in ms: *example 50 ms*<br />

```
./wan_emulation.sh tc_delay eth0 50
```

###Remove propagation delay 
This command removes the propagation delay on the traffic over the specified interface.<br />
**INPUT PARAMETERS**<br />
- Device interface that introduces the delay on the traffic: *example eth0*<br />

```
./wan_emulation.sh tc_del_delay eth0 
```
##Note
This scripts have been used to emulate the WAN bottleneck link in the paper:
- G. Carlucci, L. De Cicco, S. Holmer, and S. Mascolo **[Analysis and Design of the Google Congestion Control for Web Real-time Communication (WebRTC)](http://c3lab.poliba.it/images/6/65/Gcc-analysis.pdf)** *in Proc. og ACM Mmsys 2016, Klagenfurt, Austria, May 2016* 

##References
[Emulating wide area network delays](http://www.linuxfoundation.org/collaborate/workgroups/networking/netem#Emulating_wide_area_network_delays)

