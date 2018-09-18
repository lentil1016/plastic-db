#!/bin/bash

exec gosu mysql mysqld --skip-networking --socket="/var/run/mysqld/mysqld.sock" 2>&1 >/dev/null &
pid=$!

SOCKET="/var/run/mysqld/mysqld.sock"
mysql="mysql --protocol=socket -uroot -hlocalhost -pucds --socket=${SOCKET}"

for i in {30..0}; do
	if echo 'SELECT 1' | ${mysql} &> /dev/null; then
		break
	fi
	echo 'MySQL init process in progress...'
	sleep 1
done
if [ "$i" = 0 ]; then
	echo >&2 'MySQL init process failed.'
	exit 1
fi

for f in /docker-entrypoint-initdb.d/*; do
	case "$f" in
		*.sql)    echo "$0: running $f"; cat $f| mysql --protocol=socket --socket="/var/run/mysqld/mysqld.sock" -uroot -p${MYSQL_ROOT_PASSWORD}; echo ;;
		*)        echo "$0: ignoring $f" ;;
	esac
	echo
done

sleep 3
if ! kill -s TERM "$pid" || ! wait "$pid"; then
	echo >&2 'MySQL init process failed.'
	exit 1
fi

exec gosu mysql mysqld

