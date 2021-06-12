


function nmap {
	if [ ! -d ./nmap ]; then
		 mkdir nmap 
	fi
	if [ -f "masscan-$host.txt" ]; then
		# cat masscan-$host.txt | awk '{print $4}'|sed "s/\/.*//g" > ports-$host.txt
		read -p "(U:<udp port separated by ,>,T:<tcp port sep by ,>)ports::>" ports
		if [  -n "$ports" ]; then
		xterm -si -hold -title "nmap scanning "$host -geometry  100x20+0+0 -bg black -fg green -e nmap -v -sC -sV -oA nmap/nmap-$host -sU -sT -p$ports $host & return 
		else
			continue
		fi
		 
	else
		xterm -si -hold -title "nmap scanning "$host -geometry  100x20+0+0 -bg black -fg green -e nmap -v -sC -sV -oA nmap/nmap-$host $host & return
	fi
	 

}

function masscan {
	xterm -si -hold -title "masscan scanning "$host -geometry  100x20+0+0 -bg black -fg green -e "masscan -p1-65535,U:1-655 $host --rate=1000 -e tun0 | tee masscan-$host.txt" &return
}

function uniscan {

	xterm -si -hold -title "scanning uniscan "$host -geometry 109x20-0+0 -bg black -fg green -e "uniscan -u http://$host/ -qweds | tee uniscan-$host.txt" & return 

}

function dirb {
	if [ ! -f "$wlist" ]; then
		wlist=
	fi

	xterm -si -hold -title "scanning dirb "$host -geometry  100x20+0-0 -bg black -fg green -e "dirb http://$host/  $wlist -o dirb-$host.txt" & return 

}

function curl {

	xterm -si -hold -title "scanning curl "$host -geometry  109x20-0-0 -bg black -fg green -e "curl -s -X HEAD -I http://$host/ | tee -a curl-$host.txt ; echo -e '----------------COMMENTS--------------\n' ; curl -s http://$host/ | grep -i '\/\*\|<\!' | tee -a curl-$host.txt" & return 

}

function ffuf {
	while true; do
		read -p "Domain Name::" domain
		if [ -n "$domain" ] ; then
			echo "Domain Name is :: "$domain
			echo "1) yes"
			echo "2) no"
			echo -n "is it Correct ? Type option number (1 or 2)::"
			read choice
			case $choice in
				1 ) break ;;
				2 ) continue ;;
				* ) echo "Unknown option. Please choose again"; continue ;;
			esac
		else
			return
		fi
		  
	done
	while true; do
		read -p "Wordlist (default:/usr/share/wordlists/dirb/common.txt)::" wdlst		
		if [ -z "$wdlst" ]; then
			wdlst="/usr/share/wordlists/dirb/common.txt"
			echo "Given Wordlist is ::"$wdlst
			break;
		elif [ ! -f "$wdlst" ]; then
			echo "file NOT Exist"
			continue
		else
			break;
		fi
	done
	xterm -si -hold -title "scanning ffuf dns "$host -geometry  100x20+350+250 -bg black -fg green -e ffuf -w $wdlst -u http://$domain/ -H 'Host: FUZZ.'$domain -fs 20750 -o ffuf-$host.txt & return
	
}

function gobuster_dir {
	read -p "wordlist for gobuster_dir::" wlistgo 
	read -p "host or domain::" hst
	if [ ! -f "$wlistgo" ]; then
		wlistgo="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
	fi
	if [ -z "$hst" ]; then
		hst=$host
	fi
	xterm -si -hold -title "scanning gobuster_dir "$host -geometry  100x20+0-0 -bg black -fg green -e gobuster dir -u http://$hst/ -w $wlistgo -o gb_dir-$host.out & return

}

function gobuster_vhost {
	while true; do
		read -p "wordlist for gobuster_vhost::" wlistgo
		if [ -f "$wlistgo" ];then
			break
		else
			if [ -z "$wlistgo" ];then
				wlistgo="/usr/share/wordlists/dirb/common.txt"
				break
			else
				echo "File Not Exist::$wlistgo"
				continue
			fi
		fi
	done
	read -p "host or domain::" hst
	if [ -z "$hst" ]; then
		hst=$host
	fi
	xterm -si -hold -title "scanning gobuster_vhost "$host -geometry  100x20+0-50 -bg black -fg green -e gobuster vhost -u http://$hst/ -w $wlistgo -o gb_vhost-$host.out & return

}


function all {

	nmap & uniscan & dirb & curl & masscan & return

}

function hosts {

	while true; do
		read -p "["`pwd`"] IP ADDR::" host
		if [ -n "$host" ]; then
			masscan
			break
		else
			echo "host not define"
			continue
		fi
	done
	return

}

function main {
	cwd=`pwd`
	hosts
	while true; do
			clear
			echo "Press ctrl+c for stop all running services"
			echo  "present HOST="$host
			echo
			echo  "      0) all ( restart all default scan ) "
			echo  "      1) nmap"
			echo  "      2) masscan"
			echo  "      3) uniscan"
			echo  "      4) dirb"
			echo  "      5) curl"
			echo  "      6) ffuf dns"
			echo  "      7) gobuster_dir wordlist"
			echo  "      8) gobuster_vhost wordlist"
			echo  "      9) dirb custom wordlist"
			echo  "     10) change Host (IP)"
                        echo  "     11) exit"
			echo 
			echo  -n '['$cwd']> '
			read yn
			case $yn in
				0 ) all ; continue;;
				1 ) nmap ; continue;;
				2 ) masscan ; continue;;
				3 ) uniscan ; continue;;
				4 ) dirb ; continue;;
				5 ) curl ; continue;;
				6 ) ffuf ; continue;;
				7 ) gobuster_dir ; continue;;
				8 ) gobuster_vhost ; continue;;
				9 ) read -p "wordlist for dirb::" wlist ; dirb; continue ;;
			       10 ) hosts ; continue;;
			       11 ) break ;;
				* ) echo "invalid option number" ; continue ;;
			esac
	done

}
main
