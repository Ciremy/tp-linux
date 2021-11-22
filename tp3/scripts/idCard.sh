path=$(pwd)
echo $path
machine=$(hostname)
echo "Machine name : $machine"
temp=$(cat /etc/os-release)
os=$(echo $temp | cut -d " " -f1 | cut -d '"' -f2)
osVersion=$(echo $temp | cut -d " " -f2 | cut -d '"' -f2)
echo "OS : $os and kernel version is $osVersion"
ip=$(ip a show wlp2s0| grep "inet "| cut -d "/" -f1| tr -s " "|cut -d " " -f3)
echo "IP : $ip"
dispoRam=$(free | grep Mem: | tr -s " " | cut -d " " -f7)
totalRam=$(free | grep Mem: | tr -s " " | cut -d " " -f2)
procname=$(ps -aux --sort -%mem | head -n 6 | awk '{print "- " $11}' | tail -n 5)
nameports=$(lsof -i -P | grep LISTEN | uniq -w 20 | awk '{print "- " $9 " : " $1}' | tr ":" " " | awk '{print "- " $3 " : " $4}')
echo "RAM : $dispoRam / $totalRam KB"
echo "Disque : $(df -h / | grep dev | awk '{print $4}' | tr -d 'G') Go left"
echo "Top 5 processes by RAM usage : "
echo "${procname}"
echo "listening port : "
echo "${nameports}"
echo "Here's your random cat : $(curl -s https://api.thecatapi.com/v1/images/search | cut -d"," -f3 | cut -d'"' -f4)"

#tr -s " " delete multiple space