#!/usr/bin/env bash

#$1 - parameter; $2 - value; $3 - default value; $4 - file;
Template() {             
	[[ -z "$2" ]] &&  sed -i "s/{{ $1 }}/$3/g" $4 || sed -i "s/{{ $1 }}/$2/g" $4
}

if [ -z "$LOCAL_IP" ]; then
	LOCAL_IP=`ip addr|grep -vE '127.0.0.1|inet6'|grep inet|awk '{print $2}'|awk -F '/' '{print $1}'`
fi

for role in 1 2 3; do
	CONF="/redis/config/redis-${role}.conf"
	Template local_ip "$LOCAL_IP" 127.0.0.1 $CONF
	echo "slave-announce-ip $LOCAL_IP" >> $CONF
	redis-server ${CONF}
done

dockerize -wait tcp://127.0.0.1:6379
CONF="/redis/config/sentinel.conf"
Template local_ip "$LOCAL_IP" 127.0.0.1 $CONF
Template master_name "$MASTER_NAME" server-1M $CONF
Template quorum "$QUORUM" 2 $CONF
Template port "$SENTINEL_PORT" 26379 $CONF
redis-sentinel ${CONF}
