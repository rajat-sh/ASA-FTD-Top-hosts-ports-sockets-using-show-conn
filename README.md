One common task in ASA/FTD troubleshooting is to find the top hosts, ports, hosts pair, socket-host pair etc using the "show conn" output file. Script will ask user how many top hosts, ports, sockets, IP pair are required.
This document is using "show conn" output, "show conn long" and "show long detail" has multiline outputs and different processing is needed. Script will ask user how many top hosts, ports, sockets, IP pair are required.
show conn output will look like following:

TCP outside 10.48.26.239:8305 inside 192.168.1.96:41815, idle 0:00:01, bytes 32564248, flags UxIO
TCP outside 3.65.105.133:443 inside 192.168.1.222:50034, idle 0:00:02, bytes 6734661, flags UxIO
TCP outside 10.48.26.239:8305 inside 192.168.1.96:47891, idle 0:00:08, bytes 13081667, flags UxIO
TCP outside 146.112.255.69:443 inside 192.168.1.222:50880, idle 0:00:55, bytes 11005, flags UxIO
UDP outside 172.31.74.20:123 inside 192.168.1.223:123, idle 0:00:08, bytes 48, flags -
TCP outside 10.0.1.10:389 inside 192.168.1.222:44914, idle 0:00:17, bytes 0, flags sxaA
UDP outside 10.0.1.135:514 inside 192.168.1.222:56219, idle 0:00:00, bytes 1141743837, flags -
TCP outside 10.0.1.11:389 inside 192.168.1.222:48668, idle 0:00:07, bytes 0, flags sxaA
TCP outside 10.0.1.202:8910 inside 192.168.1.222:49486, idle 0:00:21, bytes 0, flags sxaA
TCP outside 10.48.26.239:8305 inside 192.168.1.94:41823, idle 0:00:04, bytes 10865453, flags UxIO
TCP outside 10.48.26.239:8305 inside 192.168.1.94:57773, idle 0:00:01, bytes 9255547, flags UxIO

File are attached, site wont accept .sh files, so i changed extension to .text, however extension is optional, you can use file with any name extension.

To run

chmod u+rx tophost.text

Example

RAJATSH-M-V7QW:Desktop rajatsh$ ./tophost.txt

**Enter the show conn file name in current directory or full path name**

/Users/rajatsh/Desktop_Copy/awk_program/conn

**Enter the number of top hosts, ports, sockets, IP pair required**

10

Top IP ADDRESSs

453104 X.X.X.X

117728 X.X.X.X

107584 X.X.X.X

104944 X.X.X.X

100920 X.X.X.X

95233 X.X.X.X

92102 X.X.X.X

90200 X.X.X.X

86624 X.X.X.X

85743 X.X.X.X

Top PORTS

4461480 443

62135 80

55926 3478

30841 8443

25122 25

22008 8089

21190 3061

18470 3060

15323 5223

13332 3481

Top SOCKETS

92102 X.X.X.X:443

73109 X.X.X.X:443

68775 X.X.X.X:443

63711 X.X.X.X:443

62106 X.X.X.X:443

62027 X.X.X.X:443

61035 X.X.X.X:443

60818 X.X.X.X:443

60068 X.X.X.X:443

59513 X.X.X.X:443

Top PAIR of ADDRESS

5921 X.X.X.X<->X.X.X.X

5349 X.X.X.X<->X.X.X.X

5272 X.X.X.X<->X.X.X.X

5256 X.X.X.X<->X.X.X.X

5012 X.X.X.X<->X.X.X.X

5000 X.X.X.X<->X.X.X.X

4791 X.X.X.X<->X.X.X.X

4779 X.X.X.X<->X.X.X.X

4717 X.X.X.X<->X.X.X.X

4458 X.X.X.X<->X.X.X.X

 

I am masking all IP addresses to X.X.X.X for privacy.
