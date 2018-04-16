########################################################
# Programa: monamictlan.sh
# Descripción:
#       Obtiene las direcciones ip's que están haciendo
#       ataques de fuerza bruta y las agrega a una
#       lista negra para que el firewall las bloqué.
# Licencia: GPLv3
########################################################
#!/bin/bash -e
BLACKIP='/etc/iptables/blackip'
MESSAGE_LOG='/var/log/messages'

# Bloque peticiones de escalamiento de directorios o vulnerabildiades de la
# página web de ssh por puerto 80.
ssh_80_blackip () {
  if [ ! -e $BLACKIP ]; then
    if [ ! -e /etc/iptables ]; then
      mkdir /etc/iptables
      chmod 700 /etc/iptables
    fi
	 touch $BLACKIP
  fi
  IPNEGADAS=`grep "Bad protocol" $MESSAGE_LOG | sed "s/from /@/" | cut -d "@" -f2 | sort | uniq`

  for IP in $IPNEGADAS
  do
    grep $IP $BLACKIP
	 if [ $? -eq 1 ]; then
       /usr/sbin/iptables -t nat -A PREROUTING -s $IP -j DNAT --to-destination 192.168.11.23
       echo "$IP" >> /etc/iptables/blackip
    fi
  done
}

ssh_80_blackip
