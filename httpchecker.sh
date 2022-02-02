#!/bin/bash

#multithread proxy checker script

#USAGE:

#0) - pre installs:
#	apt install parallel proxychains4
#	pip3 install proxy.py

#1) - download proxylists from @Proxybar telegram channel

#2) - configure script 
#	threads
#	checktarget 
#	curl connect-timeout and max-time

#3) - run scrpt

#4) - create proxychains config file:
#random_chain
#chain_len = 1
#tcp_read_time_out 18000
#tcp_connect_time_out 8000
#[ProxyList]
#http x.x.x.x 3128
#http y.y.y.y 8080
#http z.z.z.z 8081
#proxies from script output

#5) run local http-proxy server with proxychains:
#	proxychains4 -f http_random_chain.conf proxy --hostname 127.0.0.1 --port 8080 --timeout 10

#6) use use BurpSuite or other bruter with local proxy

proxylist="./2022-01-31__http.txt"
outputlist="./http_result.txt"
threads=10
checktarget="https://mail.com/robots.txt"


httpWorker() {
	proxyip=$(echo $1 | cut -d ' ' -f 2)
    proxyport=$(echo $1 | cut -d ' ' -f 3)

	echo Testing proxy: $1
	status_code=$(curl -s -k --max-time 10 --connect-timeout 7 --write-out %{http_code} --output /dev/null -x http://$proxyip:$proxyport $2 )
	
	if [[ "$status_code" -ne 000 ]] ; then
		echo Proxy $1 success !
		echo $1 >> $3
	fi
}

export -f httpWorker 

cat $proxylist | parallel -j$threads httpWorker {} $checktarget $outputlist

