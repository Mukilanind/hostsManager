#!/usr/local/bin/bash
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi
hostsFile=$(sed -e "s/[[:space:]]\+/ /g" /etc/hosts | tr [A-Z] [a-z])
commentedMsg="##
# Host Database
#
# localhost is used to configure the loopback interface
# when the system is booting.  Do not change this entry.
##
"
OLDIFS=$IFS
IFS=$'\n'
declare -A HOSTMAP 
for line in $hostsFile; do
  IFS=$'\n'	
  if [[ ! $line == \#* ]]
  then
  	IFS=$OLDIFS read -r -a ADDR <<< "$line"
  	crntHost=${HOSTMAP["${ADDR[0]}"]}
  	if [[ ${crntHost+abc} ]]; then
  		HOSTMAP["${ADDR[0]}"]+=${ADDR[@]:1}
  	else
  		HOSTMAP["${ADDR[0]}"]=${ADDR[@]:1}
  	fi
  fi
done
case "$1" in
  list)
    for key in "${!HOSTMAP[@]}"; 
	do
		printf "%0.s-" {1..50}
		printf "\n"
		printf "%0s $key \n"
		printf "\n"
		IFS=$OLDIFS read -r -a ADDR <<< "${HOSTMAP[$key]}"
		for host in ${ADDR[@]};
		do
			printf	"% 3s $host \n";
		done				
	done
	printf "\n\n"
	;;
  organize)
		if test -f /etc/hostManager_Backup;then
			echo "Organizing /etc/hosts"
		else
			sudo cp /etc/hosts /etc/hostManager_Backup;
			echo "Backup of HOSTS Created at /etc/hostManager_Backup"
		fi
		organizedHost=$commentedMsg
        for key in "${!HOSTMAP[@]}"; 
		do
			organizedHost+="$key ";
			for host in ${HOSTMAP[$key]};
			do
				organizedHost+="$host \n\n";
			done				
		done
		> /etc/hosts
		printf "$organizedHost" >> /etc/hosts
        ;;

  *)
        echo "Usage: "
        echo "	hostManager [list|organize]"
        echo "Examples:"
        echo "	hostManager list"
        echo "	hostManager organize"
        exit 1
        ;;
esac

exit 0;