#!/bin/bash

# Prompt the user for the input file
read -p "Enter the input file name: " input_file
read -p "Enter the number of top hosts, ports, sockets, IP pair required: " nums

# AWK script to process the file
awk '
BEGIN {
    print "Processing lines starting with TCP, UDP, or ICMP...";
}

/^TCP|^UDP|^ICMP/ {
    #print $0;  # Print the entire matching line
    #print "Third column:", $3;  # Print the third column
    #print "Fifth column:", $5;  # Print the fifth column
    array1[length(array1) + 1] = $3;  # Store third column in array1
    array1[length(array1) + 1] = $5;  # Store fifth column in array1
}

END {
    #print "Array1 Elements (before removing commas):";
    for (i = 1; i <= length(array1); i++) {
        #print array1[i];
    }
    
    #print "Array1 Elements (after removing commas):";
    for (i = 1; i <= length(array1); i++) {
        gsub(",", "", array1[i]);  # Remove commas
        #print array1[i];
    }

    # Count unique substrings before ":"
    #print "Unique substrings before colon:";
    for (i = 1; i <= length(array1); i++) {
        split(array1[i], arr, ":");
        pre[arr[1]]++;
    }
    for (key in pre) print key, pre[key] > "ip.temp";

    # Count unique substrings after ":"
    #print "Unique substrings after colon:";
    for (i = 1; i <= length(array1); i++) {
        split(array1[i], arr, ":");
        post[arr[2]]++;
    }
    for (key in post) print key, post[key] > "ports.temp";

    # Count unique elements
    #print "Unique elements in array1:";
    for (i = 1; i <= length(array1); i++) {
        unique[array1[i]]++;
    }
    for (key in unique) print key, unique[key] > "sockets.temp";

    # Concatenate every alternate element
    #print "Unique concatenated substrings:";
    count = 0;
    for (i = 1; i <= length(array1); i++) {
        split(array1[i], arr, ":");
        if (count % 2 == 0) {
            concatenated[arr[1] "<-------->" arr[1]]++;
        }
        count++;
    }
    for (key in concatenated) print key, concatenated[key] > "ippair.temp";
}
' "$input_file"
cat ip.temp | sort -nrk1 | head -$nums > ip.temp1
cat ports.temp | sort -nrk1 | head -$nums > ports.temp1
cat sockets.temp | sort -nrk1 | head -$nums > sockets.temp1
cat ippair.temp | sort -nrk1 | head -$nums > ippair.temp1

echo "Top $nums IP Addresses"
cat ip.temp1

echo "Top $nums Ports"
cat ports.temp1

echo "Top $nums Sockets"
cat sockets.temp1

echo "Top $nums IP Addresses pairs"
cat ippair.temp1

rm ip.temp ip.temp1 ports.temp ports.temp1 sockets.temp sockets.temp1 ippair.temp ippair.temp1

