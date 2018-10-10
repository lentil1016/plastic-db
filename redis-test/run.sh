#!/usr/bin/env bash

set -e

#$1 - parameter; $2 - value; $3 - default value; $4 - file;
Template() {             
	[[ -z "$2" ]] &&  sed -i "s/{{ $1 }}/$3/g" $4 || sed -i "s/{{ $1 }}/$2/g" $4
}

for role in 1 2 3; do
	CONF="/redis/config/redis-${role}.conf"
	redis-server ${CONF}
done

dockerize -wait tcp://127.0.0.1:6379
CONF="/redis/config/sentinel.conf"
Template master_name "$MASTER_NAME" server-1M $CONF
Template quorum "$QUORUM" 2 $CONF
Template port "$SENTINEL_PORT" 26379 $CONF
redis-sentinel ${CONF}
