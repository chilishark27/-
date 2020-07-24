#!/bin/bash
cat <<-EOF
#####################################################
#   此脚本适用于CentOS/RedHat和Kail/Debian/Ubuntu   #
#####################################################
EOF
count=2
PS3="Enter your choice: "

os_check() {
	if [ `command -v apt` = "/usr/bin/apt" ];then
        P_M=apt-get
	elif [ `command -v yum` = "/usr/bin/yum" ];then
        P_M=yum
	fi
}

if [ $USER != root ];then
	echo "Please Use root"
	exit
fi

vmstat &>/dev/null
if [ $? -ne 0 ];then
	echo "You not installed vmstat"
	sleep 1
	echo "Now installing"
	os_check
	$P_M install -y procps
fi

iostat &>/dev/null
if [ $? -ne 0 ];then
	echo "You not installed iostat"
	sleep 1
	os_check
	echo "Now installing"
	$P_M install -y sysstat
fi

#while :
#do
#	select choice in cpu_load disk_load disk_use disk_inode mem_use tcp_status cpu_top10 mem_top10 network_traffic quit
#	do
#		case $choice in
#			cpu_load)
#				cpu_load
#				;;
#			disk_load)
#				disk_load
#				;;
#			disk_use)
#				disk_use
#				;;
#			disk_inode)
#				disk_inode
#				;;
#			mem_use)
#				mem_use
#				;;
#			tcp_status)
#				tcp_status
#				;;
#			cpu_top10)
#				cpt_top10
#				;;
#			mem_top10)
#				mem_top10
#				;;
#			network_traffic)
#				network_traffic
#				;;
#			quit)
#				exit
#				;;
#			*)
#				echo "------------------------------------------------"
#				echo "Input 1-10 number,Please Enter again!!!"
#				echo "------------------------------------------------"
#
#		esac
#	done
#done

cpu_load() {
#	local color=`echo -e "\033[31m 参考值${i}\033[0m"`
#	local color2=`echo -e "\e[31m User Use: ${USER}\e[0m"`
#	local color3=`echo -e "\e[31m System Use: ${SYSTEM}\e[0m"`
#	local color4=`echo -e "\e[31m Util: ${UTIL}\e[0m"`
#	local color5=`echo -e "\e[31m I/O Wait Time: ${IOWAIT}\e[0m"`
	#查看CPU负载
	echo "-----------------------------------------------------------------"
	i=1
	while [[ $i -le $count ]]
	do
		USER=`vmstat -Sm | awk '{if(NR==3)print $13"%"}'`
                SYSTEM=`vmstat -Sm | awk '{if(NR==3)print $14"%"}'`
                UTIL=`vmstat -Sm | awk '{if(NR==3)print 100-$15"%"}'`
                IOWAIT=`vmstat -Sm | awk '{if(NR==3)print $16"s"}'`

		local color=`echo -e "\033[31m 参考值${i}\033[0m"`
		local color2=`echo -e "\e[31m User Use: ${USER}\e[0m"`
		local color3=`echo -e "\e[31m System Use: ${SYSTEM}\e[0m"`
		local color4=`echo -e "\e[31m Util: ${UTIL}\e[0m"`
		local color5=`echo -e "\e[31m I/O Wait Time: ${IOWAIT}\e[0m"`
		echo -e "$color"
#		USER=`vmstat -Sm | awk '{if(NR==3)print $13"%"}'`
#		SYSTEM=`vmstat -Sm | awk '{if(NR==3)print $14"%"}'`
#		UTIL=`vmstat -Sm | awk '{if(NR==3)print 100-$15"%"}'`
#		IOWAIT=`vmstat -Sm | awk '{if(NR==3)print $16"s"}'`
		echo "$color2"
		echo "$color3"
		echo "$color4"
		echo "$color5"
		let i++
		sleep 1
	done
	echo "-----------------------------------------------------------------"
}

disk_load() {
#	local color=`echo -e "\e[32m Util:\e[0m"`
#	local color2=`echo -e "\e[32m Util:\n$UTIL\e[0m"`
#	local color3=`echo -e "\e[32m Read/s:\n$READ\e[0m"`
#	local color4=`echo -e "\e[32m Write/s:\n$WRITE\e[0m"`
#	local color5=`echo -e "\e[32m I/O wait time:\n$IOWAIT\e[0m"`
	i=1
	echo "-----------------------------------------------------------------"
	while [[ $i -ne $count ]]
	do
		UTIL=`iostat -x -k | awk '/^[n|s]/{print $1,$NF"%"}'`
		READ=`iostat -x -k | awk '/^[n|s]/{print $1,$6"KB/s"}'`
		WRITE=`iostat -x -k | awk '/^[n|s]/{print $1,$7"KB/s"}'`
		IOWAIT=`vmstat -Sm | awk '{if(NR==3)print $16"s"}'`
		local color=`echo -e "\e[32mUtil:\e[0m"`
        local color2=`echo -e "\e[32mUtil:\n$UTIL\e[0m"`
        local color3=`echo -e "\e[32mRead/s:\n$READ\e[0m"`
        local color4=`echo -e "\e[32mWrite/s:\n$WRITE\e[0m"`
        local color5=`echo -e "\e[32mI/O wait time:\n$IOWAIT\e[0m"`

		echo "$color2"
		echo "$color3"
		echo "$color4"
		echo "$color5"
		let i++
		sleep 1
	done
	echo "-----------------------------------------------------------------"
}

disk_use() {
#	local color=`echo -e "\e[33m Disk_Total:\n$DISK_TOTAL1"`
#	local color2=`echo -e "\e[33m Disk_Total:\n$DISK_TOTAL2"`
	echo "查看磁盘情况"
	DISK_LOG=/tmp/Disk.log
	#DISK_TOTAL=`fdisk -l | awk '/^Disk.*bytes/&&/\/dev/{print $2" ";printf "%d",$3;print "Gb"}'
	DISK_TOTAL1=`lsblk -l | awk '/\<n.*n1\>/{print $1" ";printf "%.1f",$4;print "G"}'`
	DISK_TOTAL2=`lsblk -l | awk '/^c/{print $1" ";printf "%.1f",$4;print "G"}'`
	USE_RATE=`df -h | awk '/^\/dev/{print $5}'`
	local color=`echo -e "\e[33mDisk_Total:\n$DISK_TOTAL1"`
    local color2=`echo -e "\e[33mDisk_Total:\n$DISK_TOTAL2"`

	for i in $USE_RATE
	do
		i=`echo $i |awk -F"%" '{print $1}'`
		if [ $i -gt 90 ];then
			PART=`df -h | awk '{if(int($5)=='''$i''')print $1}'`
			echo "$PART = ${i}%" >> $DISK_LOG
		fi
	done
	echo "$color"
	echo "$color2"
	if [ -f $DISK_LOG ];then
		echo "Cat $DISK_LOG"
		sleep 2
		cat $DISK_LOG
		echo "-----------------------------------------------------------------"
		rm -f $DISK_LOG
		echo "-----------------------------------------------------------------"
	fi
}

disk_inode() {
#	local color=`echo -e "\e[33m Inode Use:\n$INODE_USE\e[0m"`
	#local color2=
	DISK_INODE_LOG=/tmp/Disk_Inode.log
	INODE_USE=`df -i | awk '/^\/dev/{print $1" ";printf "%d",$5;print "%"}'`
	local color=`echo -e "\e[33mInode Use:\n$INODE_USE\e[0m"`

	for i in $INODE_USE
	do
		if [ -f $DISK_INODE_LOG ];then
			PART=`df -h | awk '{if(int($5)== '''$i''') print $1}'`
		fi
	done
	echo "$color"
	if [ -f $DISK_INODE_LOG ];then
		cat $DISK_INODE_LOG
		echo "-----------------------------------------------------------------"
		sleep 2
		rm -f $DISK_INODE_LOG
		echo "-----------------------------------------------------------------"
	fi
}

mem_use() {
	#查看内存使用
	echo "-----------------------------------------------------------------"
#$	local color=`echo -e "\e[34mMem Total:\n$MEM_TOTAL\e[0m"`
#$	local color2=`echo -e "\e[34mMem Use:\n$MEM_USE\e[0m"`
#$	local color3=`echo -e "\e[34mMem Free:\n$MEM_FREE\e[0m"`
#$	local color4=`echo -e "\e[34mMem Cache:\n$MEM_CACHE\e[0m"`
#$	local color5=`echo -e "\e[34mMem Usage:\n$MEM_USAGE\e[0m"`
	MEM_TOTAL=`free -m | awk '/^Mem:/{printf "%.1f",$2/1024}END{print "G"}'`
	MEM_USE=`free -m | awk '/^Mem:/{printf "%.1f",$3/1024}END{print "G"}'`
	MEM_FREE=`free -m | awk '/^Mem:/{printf "%.1f",$4/1024}END{print "G"}'`
	MEM_CACHE=`free -m | awk '/^Mem:/{printf "%.1f",$6/1024}END{print "G"}'`
	mem_total=`free -m | awk '/^Mem:/{print $2}'`
	mem_total1=`free -m | awk '/^Mem:/{print $3}'`
	MEM_USAGE=$((mem_total1*100/mem_total))

        local color=`echo -e "\e[34mMem Total:\n$MEM_TOTAL\e[0m"`
        local color2=`echo -e "\e[34mMem Use:\n$MEM_USE\e[0m"`
        local color3=`echo -e "\e[34mMem Free:\n$MEM_FREE\e[0m"`
        local color4=`echo -e "\e[34mMem Cache:\n$MEM_CACHE\e[0m"`
        local color5=`echo -e "\e[34mMem Usage:\n$MEM_USAGE%\e[0m"`

	if [ $MEM_USAGE -gt 90 ];then
		echo "Warning!!!! Memory is more than 90%!!!!!"
	else
		echo "Memory is less than 90%"
	fi
	echo "-----------------------------------------------------------------"
	echo $color
	echo $color2
	echo $color3
	echo $color4
	echo $color5
	echo "-----------------------------------------------------------------"
}

tcp_status() {
	#查看tcp连接状态
	#local color=`echo -e "\e[35m Mem Usage:\n$TCP_STATUS\e[0m"`
	echo "-----------------------------------------------------------------"
	TCP_STATUS=`ss -ant | awk '!/^State/{Status[$1]++}END{for(i in Status) print i,Status[i]}'`
	local color=`echo -e "\e[35m  TCP Connection Status:\n$TCP_STATUS\e[0m"`
	echo $color
	echo "-----------------------------------------------------------------"
}

cpu_top10() {
	#查看CPU利用率前十
	 echo "-----------------------------------------------------------------"
	CPU_LOG=/tmp/cpu.log
	i=1
	while [[ $i -le 2 ]]
	do
		ps aux | awk '{if($3>0.1){{printf "PID: " $2 "CPU: "$3"% --> "}for(i=11;i<=NF;i++)if(i==NF)printf $i"\n";else printf $i}}' | sort -k3 -nr | head -10 > $CPU_LOG
		if [[ -n `cat $CPU_LOG` ]];then
			echo $CPU_LOG
			echo "--------------------------------------------------"
			cat $CPU_LOG
			> $CPU_LOG
		else
			echo "No process using the Cpu"
			break
		fi
		let i++
		sleep 2
	done
	 echo "-----------------------------------------------------------------"

}
mem_top10() {
	MEM_LOG=/tmp/mem.txt
        i=1
        while [[ $i -le 2 ]];
        do
                ps aux | awk '{if($4>0.1){{printf "PID: "$2" Memory: "$4"% --> "}for(i=1;i<=NF;i++)if(i==NF)printf $i"\n";else printf $i}}' | sort -k4 -rn | head -10 > $MEM_LOG
                if [ -n $MEM_LOG ];then
                        echo "$color"
                        cat $MEM_LOG
                        > $MEM_LOG
                else
                        echo "Nothing to do!"
                fi
		let i++
		sleep 2
        done
        echo "-------------------------------"
}

network_traffic() {
#	local color=`echo -e "\e[36mIn ------- Out\e[0m"`
#	local color1=`echo -e "\e[36m${In}MB/s      ${Out}MB/s\e[0m"`
        while :
        do
                read -p "Enter your network card name(eth[0-9] or ens[0-9]): " eth
                if [ `ifconfig | grep -c "\<$eth\>"` -eq 1 ];then
                        break
                else
                        echo "Input format error or Don't have the network card!Input again!!!!"
                fi
        done
        echo "-------------------------------"
        echo -e " In ------- Out"
        i=1
        while [[ $i -le 3 ]]
        do
                OLD_RX=`ifconfig $eth | awk '/bytes/{if(NR==5)print $5;else if(NR==8){print $4}}'`
                OLD_TX=`ifconfig $eth | awk '/bytes/{if(NR==7)print $5;else if(NR==8){print $9}}'`
                sleep 1
                NEW_RX=`ifconfig $eth | awk '/bytes/{if(NR==5)print $5;else if(NR==8){print $4}}'`
                NEW_TX=`ifconfig $eth | awk '/bytes/{if(NR==7)print $5;else if(NR==8){print $9}}'`
                IN=`awk 'BEGIN{printf "%.1f\n",'$((NEW_RX-OLD_RX))'/1024/128}'`
                OUT=`awk 'BEGIN{printf "%.1f\n",'$((NEW_TX-OLD_TX))'/1024/128}'`
		local color=`echo -e "\e[36mIn ------- Out\e[0m"`
       		local color1=`echo -e "\e[36m${IN}MB/s      ${OUT}MB/s\e[0m"`

                echo "$color1"
                let i++
                sleep 1
        done
        echo "-------------------------------"
}
while :
do
        select choice in cpu_load disk_load disk_use disk_inode mem_use tcp_status cpu_top10 mem_top10 network_traffic quit
        do
                case $choice in
                        cpu_load)
                                cpu_load
				break
                                ;;
                        disk_load)
                                disk_load
				break
                                ;;
                        disk_use)
                                disk_use
				break
                                ;;
                        disk_inode)
                                disk_inode
				break
                                ;;
                        mem_use)
                                mem_use
				break
                                ;;
                        tcp_status)
                                tcp_status
				break
                                ;;
                        cpu_top10)
                                cpu_top10
				break
                                ;;
                        mem_top10)
                                mem_top10
				break
                                ;;
                        network_traffic)
                                network_traffic
				break
                                ;;
                        quit)
                                exit
                                ;;
                        *)
                                echo "------------------------------------------------"
                                echo "Input 1-10 number,Please Enter again!!!"
                                echo "------------------------------------------------"

                esac
        done
done

