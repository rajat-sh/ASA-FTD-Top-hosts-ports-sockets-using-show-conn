# ASA-FTD-Top-hosts-ports-sockets-using-show-conn

One common task in ASA/FTD troubleshooting is to find the top hosts, ports, hosts pair, socket-host pair etc using the "show conn" output file. This document is using "show conn" output, "show conn long" and "show long detail" has multiline outputs and different processing is needed. I will explain the logic, goal is readers can use this as a framework and do similar tasks, lot of file processing tasks can be mapped to this type of programs.

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

This kind of task in general can be mapped to unique string count issue. I will be using awk and other common linux tools to do this task.

Example 1

In this we will calculate top hosts from file. First is to prepare the input so each data that we are interested to process is a unique column i.e each IP address is on unique line in output.

Code i am using for this task is following:

base) RAJATSH-M-V7QW:Desktop rajatsh$ cat prep.awk 
 
#Next line is setting the output field separator to new line

BEGIN{OFS = "\n"}

{

#Next line is removing the commas from each line

gsub(",", "", $0)

#Next line is checking if the first column value is TCP,UDP,ICMP,GRE as for portless connections such as EIGRP etc column will be different. 

if($1 == "TCP" || $1 == "UDP" || $1 == "ICMP" || $1 == "GRE")

{

#Next two line removes the ":" between the IP address and ports.

sub(":", " ", $0)

sub(":", " ", $0)

print $3,$6

}

else

{ #Next line is printing the IP address in connections without ports such as EIGRP

print $3,$5

}

}

END{}
 

If it take output above and pipe to this awk program, result is something like below:


(base) RAJATSH-M-V7QW:Desktop rajatsh$ echo "TCP outside 10.48.26.239:8305 inside 192.168.1.96:41815, idle 0:00:01, bytes 32564248, flags UxIO

TCP outside 3.65.105.133:443 inside 192.168.1.222:50034, idle 0:00:02, bytes 6734661, flags UxIO

TCP outside 10.48.26.239:8305 inside 192.168.1.96:47891, idle 0:00:08, bytes 13081667, flags UxIO

TCP outside 146.112.255.69:443 inside 192.168.1.222:50880, idle 0:00:55, bytes 11005, flags UxIO

UDP outside 172.31.74.20:123 inside 192.168.1.223:123, idle 0:00:08, bytes 48, flags -

TCP outside 10.0.1.10:389 inside 192.168.1.222:44914, idle 0:00:17, bytes 0, flags sxaA

UDP outside 10.0.1.135:514 inside 192.168.1.222:56219, idle 0:00:00, bytes 1141743837, flags -

TCP outside 10.0.1.11:389 inside 192.168.1.222:48668, idle 0:00:07, bytes 0, flags sxaA

TCP outside 10.0.1.202:8910 inside 192.168.1.222:49486, idle 0:00:21, bytes 0, flags sxaA

TCP outside 10.48.26.239:8305 inside 192.168.1.94:41823, idle 0:00:04, bytes 10865453, flags UxIO

TCP outside 10.48.26.239:8305 inside 192.168.1.94:57773, idle 0:00:01, bytes 9255547, flags UxIO " | awk -f prep.awk

10.48.26.239

192.168.1.96

3.65.105.133

192.168.1.222

10.48.26.239

192.168.1.96

146.112.255.69

192.168.1.222

172.31.74.20

192.168.1.223

10.0.1.10

192.168.1.222

10.0.1.135

192.168.1.222

10.0.1.11

192.168.1.222

10.0.1.202

192.168.1.222

10.48.26.239

192.168.1.94

10.48.26.239

192.168.1.94

 

As you can see above each IP address in the connection is on new line.

Next task would be to calculate the count of each IP address, following code is used for this task, this is a hashamp/associative array which will have each IP address as key and count as value and it will print key-value pair two columns in each line.


(base) RAJATSH-M-V7QW:Desktop rajatsh$ cat hashmap.awk

BEGIN{}
{a[$1]++}
END{for(x in a)print a[x]" "x}

 

 

Then we can pipe the output of the first part to this code
 
 
(base) RAJATSH-M-V7QW:Desktop rajatsh$ echo "TCP outside  10.48.26.239:8305 inside  192.168.1.96:41815, idle 0:00:01, bytes 32564248, flags UxIO 

TCP outside  3.65.105.133:443 inside  192.168.1.222:50034, idle 0:00:02, bytes 6734661, flags UxIO 

TCP outside  10.48.26.239:8305 inside  192.168.1.96:47891, idle 0:00:08, bytes 13081667, flags UxIO 

TCP outside  146.112.255.69:443 inside  192.168.1.222:50880, idle 0:00:55, bytes 11005, flags UxIO 

UDP outside  172.31.74.20:123 inside  192.168.1.223:123, idle 0:00:08, bytes 48, flags - 

TCP outside  10.0.1.10:389 inside  192.168.1.222:44914, idle 0:00:17, bytes 0, flags sxaA 

UDP outside  10.0.1.135:514 inside  192.168.1.222:56219, idle 0:00:00, bytes 1141743837, flags - 

TCP outside  10.0.1.11:389 inside  192.168.1.222:48668, idle 0:00:07, bytes 0, flags sxaA 

TCP outside  10.0.1.202:8910 inside  192.168.1.222:49486, idle 0:00:21, bytes 0, flags sxaA 

TCP outside  10.48.26.239:8305 inside  192.168.1.94:41823, idle 0:00:04, bytes 10865453, flags UxIO 

TCP outside  10.48.26.239:8305 inside  192.168.1.94:57773, idle 0:00:01, bytes 9255547, flags UxIO " |  awk -f prep.awk | awk -f hashmap.awk 

1 10.0.1.202

1 146.112.255.69

6 192.168.1.222

2 192.168.1.94

1 192.168.1.223

2 192.168.1.96

1 172.31.74.20

1 10.0.1.135

1 3.65.105.133

4 10.48.26.239

1 10.0.1.10

1 10.0.1.11
 
As seen above first column is count and second column is IP address value.
 
Then you can pipe this to sort to sort by count value.
 
(base) RAJATSH-M-V7QW:Desktop rajatsh$ echo "TCP outside  10.48.26.239:8305 inside  192.168.1.96:41815, idle 0:00:01, bytes 32564248, flags UxIO 

TCP outside  3.65.105.133:443 inside  192.168.1.222:50034, idle 0:00:02, bytes 6734661, flags UxIO 

TCP outside  10.48.26.239:8305 inside  192.168.1.96:47891, idle 0:00:08, bytes 13081667, flags UxIO 

TCP outside  146.112.255.69:443 inside  192.168.1.222:50880, idle 0:00:55, bytes 11005, flags UxIO 

UDP outside  172.31.74.20:123 inside  192.168.1.223:123, idle 0:00:08, bytes 48, flags - 

TCP outside  10.0.1.10:389 inside  192.168.1.222:44914, idle 0:00:17, bytes 0, flags sxaA 

UDP outside  10.0.1.135:514 inside  192.168.1.222:56219, idle 0:00:00, bytes 1141743837, flags - 

TCP outside  10.0.1.11:389 inside  192.168.1.222:48668, idle 0:00:07, bytes 0, flags sxaA 

TCP outside  10.0.1.202:8910 inside  192.168.1.222:49486, idle 0:00:21, bytes 0, flags sxaA 

TCP outside  10.48.26.239:8305 inside  192.168.1.94:41823, idle 0:00:04, bytes 10865453, flags UxIO 

TCP outside  10.48.26.239:8305 inside  192.168.1.94:57773, idle 0:00:01, bytes 9255547, flags UxIO " |  awk -f prep.awk | awk -f hashmap.awk | sort -nrk1

6 192.168.1.222

4 10.48.26.239

2 192.168.1.96

2 192.168.1.94

1 3.65.105.133

1 192.168.1.223

1 172.31.74.20

1 146.112.255.69

1 10.0.1.202

1 10.0.1.135

1 10.0.1.11

1 10.0.1.10
 
 
 
 
To run this on a show conn file, here name if file is "connu" to show top 20 hosts, syntax would be following
 
 
(base) RAJATSH-M-V7QW:Desktop rajatsh$ cat connu | awk -f prep.awk | awk -f hashmap.awk | sort -nrk1 | head -20
 
I am masking IP address to x.x.x.x as sample file contains some Public address.
 

56638 x.x.x.x

14716 x.x.x.x

13448 x.x.x.x

13118 x.x.x.x

12619 x.x.x.x

12615 x.x.x.x

12218 x.x.x.x

11982 x.x.x.x

11367 x.x.x.x

11214 x.x.x.x

11159 x.x.x.x

10862 x.x.x.x

10828 x.x.x.x

10767 x.x.x.x

10741 x.x.x.x

10706 x.x.x.x

10633 x.x.x.x

10607 x.x.x.x

10512 x.x.x.x

10510 x.x.x.x
 
You can use GREP to filter the connections that you need to process.
 
e.g

for TCP

grep TCP  connu | awk -f prep.awk | awk -f hashmap.awk | sort -nrk1 | head -20

for UDP

grep UDP  connu | awk -f prep.awk | awk -f hashmap.awk | sort -nrk1 | head -20

for ICMP

grep ICMP  connu | awk -f prep.awk | awk -f hashmap.awk | sort -nrk1 | head -20

for EIGRP

grep EIGRP  connu | awk -f prep.awk | awk -f hashmap.awk | sort -nrk1 | head -20

for GRE

grep GRE  connu | awk -f prep.awk | awk -f hashmap.awk | sort -nrk1 | head -20
 
you can also use regex to filter what you need for particular case, e.g you only need to check 443 connections
 
grep ":443 "  connu | awk -f prep.awk | awk -f hashmap.awk | sort -nrk1 | head -20
 
 
Also for context connu file contains around 600k connections
 

(base) RAJATSH-M-V7QW:Desktop rajatsh$ wc -l connu

  628849 connu

(base) RAJATSH-M-V7QW:Desktop rajatsh$ ls -lh connu

-rw-r--r--  1 rajatsh  staff    65M Oct 20 12:35 connu
 
 
Also it is quite scalable for CPU/Mem usage, more importantly memory usage (maximum resident set size) is constant around 1 Mbytes  irrespective of file size.
 
 
(base) RAJATSH-M-V7QW:Desktop rajatsh$ date; /usr/bin/time -l -h cat connu | awk -f prep.awk | awk -f hashmap.awk | sort -nrk1 | head -20; date

Sat Nov  2 20:51:28 CET 2024

4.15s real 0.00s user 0.04s sys

             1327104  maximum resident set size
             
                   0  average shared memory size
                   
                   0  average unshared data size
                   
                   0  average unshared stack size
                 
                 194  page reclaims
                 
                   
                   2  page faults
                   
                   0  swaps
                   
                   0  block input operations
                   
                   0  block output operations
                   
                   0  messages sent
                   
                   0  messages received
                   
                   0  signals received
                
                4160  voluntary context switches
                 
                 135  involuntary context switches
           
           189503143  instructions retired
           
           138920617  cycles elapsed
           
             1164224  peak memory footprint

56638 x.x.x.x

14716 x.x.x.x

13448 x.x.x.x

13118 x.x.x.x

12619 x.x.x.x

12615 x.x.x.x

12218 x.x.x.x

11982 x.x.x.x

11367 x.x.x.x

11214 x.x.x.x

11159 x.x.x.x

10862 x.x.x.x

10828 x.x.x.x

10767 x.x.x.x


Sat Nov  2 20:51:33 CET 2024
 
 
 
if it run it on large file, 4Gbytes file, around 39 million connections
 
(base) RAJATSH-M-V7QW:Desktop rajatsh$ wc -l conn2
 39398150 conn2
(base) RAJATSH-M-V7QW:Desktop rajatsh$ ls -lh conn2
-rw-r--r--@ 1 rajatsh  staff   4.0G Sep 10 23:37 conn2
 
 
(base) RAJATSH-M-V7QW:Desktop rajatsh$ date; /usr/bin/time -l -h cat conn2 | awk -f prep.awk | awk -f hashmap.awk | sort -nrk1 | head -20; date
Sat Nov  2 20:55:02 CET 2024
4m11.51s real 0.10s user 2.00s sys
             
             1327104  maximum resident set size
             
                   0  average shared memory size
                   
                   0  average unshared data size
                   
                   0  average unshared stack size
                 
                 206  page reclaims
                 
                   4  page faults
                   
                   0  swaps
                   
                   0  block input operations
                   
                   0  block output operations
                   
                   0  messages sent
                   
                   0  messages received
                   
                   0  signals received
              
              259634  voluntary context switches
              
                7516  involuntary context switches
          
          7083887647  instructions retired
          
          6225113100  cycles elapsed
          
             
            1164224  peak memory footprint

3568194 x.x.x.x

927108 x.x.x.x

847224 x.x.x.x

826434 x.x.x.x

794745 x.x.x.x

788449 x.x.x.x

763303 x.x.x.x

748488 x.x.x.x

710190 x.x.x.x

700556 x.x.x.x

697162 x.x.x.x

682164 x.x.x.x

678562 x.x.x.x

672494 x.x.x.x


Sat Nov  2 20:59:14 CET 2024
 
 
Example 2
 
In this we will calculate top ports from file. First is to prepare the input so each data that we are interested to process is a unique column i.e each port is on unique line in output.
 
#Next line is setting the output field separator to new line

BEGIN{OFS = "\n"}

{

     #Next line is removing the commas from each line
     
     gsub(",", "", $0)
     
     #Next line is checking if the first column value is TCP,UDP as this would be most common use case
     
     if($1 == "TCP" || $1 == "UDP")
     
     {
     
         #Next two line removes the ":" between the IP address and ports.
         
          sub(":", " ", $0)
          
          sub(":", " ", $0)
          
          print $4,$7
      
      }

}

END{}
 
we will get something like this
 

(base) RAJATSH-M-V7QW:Desktop rajatsh$ echo "TCP outside  10.48.26.239:8305 inside  192.168.1.96:41815, idle 0:00:01, bytes 32564248, flags UxIO 

TCP outside  3.65.105.133:443 inside  192.168.1.222:50034, idle 0:00:02, bytes 6734661, flags UxIO 

TCP outside  10.48.26.239:8305 inside  192.168.1.96:47891, idle 0:00:08, bytes 13081667, flags UxIO 

TCP outside  146.112.255.69:443 inside  192.168.1.222:50880, idle 0:00:55, bytes 11005, flags UxIO 

UDP outside  172.31.74.20:123 inside  192.168.1.223:123, idle 0:00:08, bytes 48, flags - 

TCP outside  10.0.1.10:389 inside  192.168.1.222:44914, idle 0:00:17, bytes 0, flags sxaA 

UDP outside  10.0.1.135:514 inside  192.168.1.222:56219, idle 0:00:00, bytes 1141743837, flags - 

TCP outside  10.0.1.11:389 inside  192.168.1.222:48668, idle 0:00:07, bytes 0, flags sxaA 

TCP outside  10.0.1.202:8910 inside  192.168.1.222:49486, idle 0:00:21, bytes 0, flags sxaA 

TCP outside  10.48.26.239:8305 inside  192.168.1.94:41823, idle 0:00:04, bytes 10865453, flags UxIO 

TCP outside  10.48.26.239:8305 inside  192.168.1.94:57773, idle 0:00:01, bytes 9255547, flags UxIO " | awk -f portprep.awk

8305

41815

443

50034

8305

47891

443

50880

123

123

389

44914

514

56219

389

48668

8910

49486

8305

41823

8305

57773
 
 
 
Next step would be same as example 1
 
 
(base) RAJATSH-M-V7QW:Desktop rajatsh$ echo "TCP outside  10.48.26.239:8305 inside  192.168.1.96:41815, idle 0:00:01, bytes 32564248, flags UxIO 

TCP outside  3.65.105.133:443 inside  192.168.1.222:50034, idle 0:00:02, bytes 6734661, flags UxIO 

TCP outside  10.48.26.239:8305 inside  192.168.1.96:47891, idle 0:00:08, bytes 13081667, flags UxIO 

TCP outside  146.112.255.69:443 inside  192.168.1.222:50880, idle 0:00:55, bytes 11005, flags UxIO 

UDP outside  172.31.74.20:123 inside  192.168.1.223:123, idle 0:00:08, bytes 48, flags - 

TCP outside  10.0.1.10:389 inside  192.168.1.222:44914, idle 0:00:17, bytes 0, flags sxaA 

UDP outside  10.0.1.135:514 inside  192.168.1.222:56219, idle 0:00:00, bytes 1141743837, flags - 

TCP outside  10.0.1.11:389 inside  192.168.1.222:48668, idle 0:00:07, bytes 0, flags sxaA 

TCP outside  10.0.1.202:8910 inside  192.168.1.222:49486, idle 0:00:21, bytes 0, flags sxaA 

TCP outside  10.48.26.239:8305 inside  192.168.1.94:41823, idle 0:00:04, bytes 10865453, flags UxIO 

TCP outside  10.48.26.239:8305 inside  192.168.1.94:57773, idle 0:00:01, bytes 9255547, flags UxIO " | awk -f portprep.awk | awk -f hashmap.awk | sort -rnk1

4 8305

2 443

2 389

2 123

1 8910

1 57773

1 56219

1 514

1 50880

1 50034

1 49486

1 48668

1 47891

1 44914

1 41823

1 41815
 
 
 
some tests:
 

(base) RAJATSH-M-V7QW:Desktop rajatsh$ ls -lh connu

-rw-r--r--  1 rajatsh  staff    65M Oct 20 12:35 connu

(base) RAJATSH-M-V7QW:Desktop rajatsh$ wc -l connu

  628849 connu

(base) RAJATSH-M-V7QW:Desktop rajatsh$ date; /usr/bin/time -l -h cat connu | awk -f portprep.awk | awk -f hashmap.awk | sort -nrk1 | head -25; date

Sat Nov  2 21:21:16 CET 2024

3.93s real 0.00s user 0.02s sys

             1327104  maximum resident set size
             
                   0  average shared memory size
                   
                   0  average unshared data size
                   
                   0  average unshared stack size
                 
                 193  page reclaims
                 
                   2  page faults
                   
                   0  swaps
                   
                   0  block input operations
                   
                   0  block output operations
                   
                   0  messages sent
                   
                   0  messages received
                   
                   0  signals received
                
                4156  voluntary context switches
                
                  35  involuntary context switches
           
           104439337  instructions retired
           
            85841344  cycles elapsed
            
             1147776  peak memory footprint

580331 443

8167 80

7426 3478

3856 8443

3333 25

2751 8089

2649 3061

2309 3060

2033 5223

1771 3481

1760 3480

1392 5061

1279 36400

898 46447

848 3479

602 5222

595 36010

588 40013

471 22

464 37777

408 53

390 40014

376 8282

370 9092

347 3065

Sat Nov  2 21:21:20 CET 2024
 
 
 
(base) RAJATSH-M-V7QW:Desktop rajatsh$ date; /usr/bin/time -l -h cat conn2 | awk -f portprep.awk | awk -f hashmap.awk | sort -nrk1 | head -25; date

Sat Nov  2 21:22:00 CET 2024

4m10.24s real 0.09s user 1.90s sys

             1327104  maximum resident set size
             
                   0  average shared memory size
                   
                   0  average unshared data size
                   
                   0  average unshared stack size
                 
                 212  page reclaims
                 
                   5  page faults
                   
                   0  swaps
                   
                   0  block input operations
                   
                   0  block output operations
                   
                   0  messages sent
                   
                   0  messages received
                   
                   0  signals received
              
              260016  voluntary context switches
              
                5644  involuntary context switches
          
          7048339914  instructions retired
          
          5975607020  cycles elapsed
          
             1147776  peak memory footprint

36355520 443

510896 80

463925 3478

242921 8443

208249 25

173313 8089

166885 3061

145465 3060

127027 5223

110627 3481

109995 3480

87690 5061

80575 36400

56572 46447

53004 3479

37924 5222

37484 36010

37042 40013

29634 22

28983 37777

25655 53

24565 40014


23686 8282

23308 9092

21857 3065

Sat Nov  2 21:26:10 CET 2024

(base) RAJATSH-M-V7QW:Desktop rajatsh$ ls -lh conn2

-rw-r--r--@ 1 rajatsh  staff   4.0G Sep 10 23:37 conn2

(base) RAJATSH-M-V7QW:Desktop rajatsh$ wc -l conn2

 39398150 conn2
 
 
 
Example 3
 
In this we will calculate top pair of IP address.
 
 
prep code
 

 


BEGIN{OFS = "\n"}

{

#Next line is removing the commas from each line

gsub(",", "", $0)

#Next line is checking if the first column value is TCP,UDP,ICMP,GRE as for portless connections such as EIGRP etc column will be different. 

if($1 == "TCP" || $1 == "UDP" || $1 == "ICMP" || $1 == "GRE")

{

#Next two line removes the ":" between the IP address and ports.

sub(":", " ", $0)

sub(":", " ", $0)

print $3"<->"$6

}

else

{ #Next line is printing the IP address pair in connections without ports such as EIGRP

print $3"<->"$5

}

}

END{}
 
result
 
 

base) RAJATSH-M-V7QW:Desktop rajatsh$ echo "TCP outside  10.48.26.239:8305 inside  192.168.1.96:41815, idle 0:00:01, bytes 32564248, flags UxIO 

TCP outside  3.65.105.133:443 inside  192.168.1.222:50034, idle 0:00:02, bytes 6734661, flags UxIO 

TCP outside  10.48.26.239:8305 inside  192.168.1.96:47891, idle 0:00:08, bytes 13081667, flags UxIO 

TCP outside  146.112.255.69:443 inside  192.168.1.222:50880, idle 0:00:55, bytes 11005, flags UxIO 

UDP outside  172.31.74.20:123 inside  192.168.1.223:123, idle 0:00:08, bytes 48, flags - 

TCP outside  10.0.1.10:389 inside  192.168.1.222:44914, idle 0:00:17, bytes 0, flags sxaA 

UDP outside  10.0.1.135:514 inside  192.168.1.222:56219, idle 0:00:00, bytes 1141743837, flags - 

TCP outside  10.0.1.11:389 inside  192.168.1.222:48668, idle 0:00:07, bytes 0, flags sxaA 

TCP outside  10.0.1.202:8910 inside  192.168.1.222:49486, idle 0:00:21, bytes 0, flags sxaA 

TCP outside  10.48.26.239:8305 inside  192.168.1.94:41823, idle 0:00:04, bytes 10865453, flags UxIO 

TCP outside  10.48.26.239:8305 inside  192.168.1.94:57773, idle 0:00:01, bytes 9255547, flags UxIO " | awk -f ippairprep.awk | awk -f hashmap.awk | sort -rnk1

2 10.48.26.239<->192.168.1.96

2 10.48.26.239<->192.168.1.94

1 3.65.105.133<->192.168.1.222

1 172.31.74.20<->192.168.1.223

1 146.112.255.69<->192.168.1.222

1 10.0.1.202<->192.168.1.222

1 10.0.1.135<->192.168.1.222

1 10.0.1.11<->192.168.1.222

1 10.0.1.10<->192.168.1.222
 
 

(base) RAJATSH-M-V7QW:Desktop rajatsh$ date; /usr/bin/time -l -h cat connu | awk -f ippairprep.awk | awk -f hashmap.awk | sort -nrk1 | head -25; date

Sat Nov  2 21:32:41 CET 2024

4.18s real 0.00s user 0.04s sys

             1327104  maximum resident set size
             
                   0  average shared memory size
                   
                   0  average unshared data size
                   
                   0  average unshared stack size
                 
                 196  page reclaims
                 
                   1  page faults
                   
                   0  swaps
                   
                   0  block input operations
                   
                   0  block output operations
                   
                   0  messages sent
                   
                   0  messages received
                   
                   0  signals received
                
                4179  voluntary context switches
                
                  85  involuntary context switches
           
           188334292  instructions retired
           
           126029031  cycles elapsed
           
             1147776  peak memory footprint

788 x.x.x.x<->x.x.x.x

710 x.x.x.x<->x.x.x.x

697 x.x.x.x<->x.x.x.x

666 x.x.x.x<->x.x.x.x

657 x.x.x.x<->x.x.x.x

637 x.x.x.x<->x.x.x.x

634 x.x.x.x<->x.x.x.x

625 x.x.x.x<->x.x.x.x

625 x.x.x.x<->x.x.x.x

589 x.x.x.x<->x.x.x.x

585 x.x.x.x<->x.x.x.x

582 x.x.x.x<->x.x.x.x

571 x.x.x.x<->x.x.x.x

553 x.x.x.x<->x.x.x.x

548 x.x.x.x<->x.x.x.x

547 x.x.x.x<->x.x.x.x

538 x.x.x.x<->x.x.x.x

534 x.x.x.x<->x.x.x.x

522 x.x.x.x<->x.x.x.x

519 x.x.x.x<->x.x.x.x

516 x.x.x.x<->x.x.x.x

511 x.x.x.x<->x.x.x.x

508 x.x.x.x<->x.x.x.x

502 x.x.x.x<->x.x.x.x

501 x.x.x.x<->x.x.x.x

Sat Nov  2 21:32:46 CET 2024
 
 
 
Example 4
 
To count IP address and port counts
 

#Next line is setting the output field separator to new line

BEGIN{OFS = "\n"}

{

#Next line is removing the commas from each line

gsub(",", "", $0)

#Next line is checking if the first column value is TCP,UDP most common case

if($1 == "TCP" || $1 == "UDP")

{

#Next two line removes the ":" between the IP address and ports.

sub(":", " ", $0)

sub(":", " ", $0)

print $3":"$4

}

}

END{}
 
 
 
(base) RAJATSH-M-V7QW:Desktop rajatsh$ date; /usr/bin/time -l -h cat connu | awk -f socket.awk | awk -f hashmap.awk | sort -nrk1 | head -25; date

Sat Nov  2 21:40:57 CET 2024

4.18s real 0.00s user 0.04s sys

             1327104  maximum resident set size
             
                   0  average shared memory size
                   
                   0  average unshared data size
                   
                   0  average unshared stack size
                 
                 194  page reclaims
                 
                   4  page faults
                   
                   0  swaps
                   
                   0  block input operations
                   
                   0  block output operations
                   
                   0  messages sent
                   
                   0  messages received
                   
                   0  signals received
                
                4182  voluntary context switches
                
                 137  involuntary context switches
           
           190422211  instructions retired
           
           136870629  cycles elapsed
           
             1147776  peak memory footprint

12218 x.x.x.x:443

9691 x.x.x.x:443

9112 x.x.x.x:443

8459 x.x.x.x:443

8249 x.x.x.x:443

8226 x.x.x.x:443

8104 x.x.x.x:443

8095 x.x.x.x:443

7976 x.x.x.x:443

7890 x.x.x.x:443

7875 x.x.x.x:443

6896 x.x.x.x:443

6439 x.x.x.x:443

6397 x.x.x.x:443

6284 x.x.x.x:443

5952 x.x.x.x:443

5090 x.x.x.x:443

4238 x.x.x.x:443

4057 x.x.x.x:443

3884 x.x.x.x:443

3855 x.x.x.x:443

3725 x.x.x.x:443

3500 x.x.x.x:443

3398 x.x.x.x:443

3162 x.x.x.x:443

Sat Nov  2 21:41:02 CET 2024
 
 
 
In summary whatever is your particular use case, prep code can be modified easily.
 
 
e.g You are interested in only checking U-Turn connections where both interface are same and count the top hosts
 

#Next line is setting the output field separator to new line

BEGIN{OFS = "\n"}

{

#Next line is removing the commas from each line

gsub(",", "", $0)

#Next line is checking if the first column value is TCP,UDP,ICMP,GRE as for portless connections such as EIGRP etc column will be different. 

if($1 == "TCP" || $1 == "UDP" || $1 == "ICMP" || $1 == "GRE")

{

#Next two line removes the ":" between the IP address and ports.

sub(":", " ", $0)

sub(":", " ", $0)

if($2==$5)

{

print $3; 

print $6;

}

}

}

END{}
 

 


 "date" and "/usr/bin/time -l -h" commands are optional i am using to check CPU and memory.
 
 Also most of the awk syntax is optional, examples are using descriptive for readability, also two or more codes can be combined etc.

 

e,g with a script like the following you can combine different parts together, it will write results to stdout, this file is test.text which is attached to this document.
 
 
(base) RAJATSH-M-V7QW:awk_program rajatsh$ cat test.sh

#!/bin/bash

echo "Enter the show conn file name in current directory or full path name"

read filename

echo "Enter the number of top hosts, ports, sockets, IP pair required"

read nums

 

echo "Top IP ADDRESSs" > ip.temp

echo "Top PORTS" > port.temp

echo "Top SOCKETS" > socket.temp

echo "Top PAIR of ADDRESS" > pair.temp

 

cat $filename | awk 'BEGIN{OFS = "\n"}

{

#Next line is removing the commas from each line

gsub(",", "", $0)

#Next line is checking if the first column value is TCP,UDP,ICMP,GRE as for portless connections such as EIGRP etc column will be different.

if($1 == "TCP" || $1 == "UDP" || $1 == "ICMP" || $1 == "GRE")

{

#Next two line removes the ":" between the IP address and ports.

sub(":", " ", $0)

sub(":", " ", $0)

print $3,$6

}

else

{ #Next line is printing the IP address in connections without ports such as EIGRP

print $3,$5

}

}

END{}' | awk 'BEGIN{}

{a[$1]++}

END{for(x in a)print a[x]" "x}

' | sort -rnk1 | head -$nums >> ip.temp &

cat $filename | awk 'BEGIN{OFS = "\n"}

{

#Next line is removing the commas from each line

gsub(",", "", $0)

#Next line is checking if the first column value is TCP,UDP as this would be most common use case

if($1 == "TCP" || $1 == "UDP")

{

#Next two line removes the ":" between the IP address and ports.

sub(":", " ", $0)

sub(":", " ", $0)

print $4,$7

}

}

END{} '  | awk 'BEGIN{}

{a[$1]++}

END{for(x in a)print a[x]" "x}

' | sort -rnk1 | head -$nums >> port.temp &

cat $filename | awk 'BEGIN{OFS = "\n"}

{

#Next line is removing the commas from each line

gsub(",", "", $0)

#Next line is checking if the first column value is TCP,UDP most common case

if($1 == "TCP" || $1 == "UDP")

{

#Next two line removes the ":" between the IP address and ports.

sub(":", " ", $0)

sub(":", " ", $0)

print $3":"$4

}

}

END{}

' | awk 'BEGIN{}

{a[$1]++}

END{for(x in a)print a[x]" "x}

' | sort -nrk1 | head -$nums >> socket.temp &

cat $filename | awk 'BEGIN{OFS = "\n"}

{

#Next line is removing the commas from each line

gsub(",", "", $0)

#Next line is checking if the first column value is TCP,UDP,ICMP,GRE as for portless connections such as EIGRP etc column will be different.

if($1 == "TCP" || $1 == "UDP" || $1 == "ICMP" || $1 == "GRE")

{

#Next two line removes the ":" between the IP address and ports.

sub(":", " ", $0)

sub(":", " ", $0)

print $3"<->"$6

}

else

{ #Next line is printing the IP address pair in connections without ports such as EIGRP

print $3"<->"$5

}

}

END{}' | awk 'BEGIN{}

{a[$1]++}

END{for(x in a)print a[x]" "x}

' | sort -nrk1 | head -$nums >> pair.temp &

 

wait

cat ip.temp port.temp socket.temp pair.temp

rm ip.temp port.temp socket.temp pair.temp

 

 

 

 
 
output
 
to run
chmod u+x test.sh
 
(base) RAJATSH-M-V7QW:awk_program rajatsh$ ./test.sh

Enter the show conn file name in current directory or full path name

conn

Enter the number of top hosts, ports, sockets, IP pair required

20

Top IP ADDRESSs

453104 x.x.x.x

117728 x.x.x.x

107584 x.x.x.x

104944 x.x.x.x

100920 x.x.x.x

95233 x.x.x.x

92102 x.x.x.x

90200 x.x.x.x

86624 x.x.x.x

85743 x.x.x.x

84430 x.x.x.x

84119 x.x.x.x

81808 x.x.x.x

81012 x.x.x.x

80879 x.x.x.x

80633 x.x.x.x

80155 x.x.x.x

79942 x.x.x.x

79176 x.x.x.x

79111 x.x.x.x

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

13292 3480

11131 5061

10231 36400

7182 46447

6416 3479

4814 5222

4759 36010

4702 40013

3735 22

3488 37777

Top SOCKETS

92102 x.x.x.x:443

73109 x.x.x.x:443

68775 x.x.x.x:443

63711 x.x.x.x:443

62106 x.x.x.x:443

62027 x.x.x.x:443

61035 x.x.x.x:443

60818 x.x.x.x:443

60068 x.x.x.x:443

59513 x.x.x.x:443

59467 x.x.x.x:443

51850 x.x.x.x:443

48497 x.x.x.x:443

48272 x.x.x.x:443

47368 x.x.x.x:443

44776 x.x.x.x:443

38342 x.x.x.x:443

31863 x.x.x.x:443

30564 x.x.x.x:443

29220 x.x.x.x:443

Top PAIR of ADDRESS

5921 x.x.x.x<->x.x.x.x

5349 x.x.x.x<->x.x.x.x

5272 x.x.x.x<->x.x.x.x

5256 x.x.x.x<->x.x.x.x

5012 x.x.x.x<->x.x.x.x

5000 x.x.x.x<->x.x.x.x

4791 x.x.x.x<->x.x.x.x

4779 x.x.x.x<->x.x.x.x

4717 x.x.x.x<->x.x.x.x

4458 x.x.x.x<->x.x.x.x

4411 x.x.x.x<->x.x.x.x

4405 x.x.x.x<->x.x.x.x

4291 x.x.x.x<->x.x.x.x

4152 x.x.x.x<->x.x.x.x

4128 x.x.x.x<->x.x.x.x

4123 x.x.x.x<->x.x.x.x

4108 x.x.x.x<->x.x.x.x

4043 x.x.x.x<->x.x.x.x

4030 x.x.x.x<->x.x.x.x

3926 x.x.x.x<->x.x.x.x

 

 

 
 
 
