# plastic-db

![](https://img.shields.io/badge/usage-Test%20only-red.svg)

Provide dockerfile for mysql and oracle that generate database images that initialized with default password and configure.
SHOULD ONLY be used in Testing!

|Database|Connect command|
|-|-|
|mysql|`mysql -uroot -hmysql -pmysql`|
|oracle|`sqlplus system/oracle@oracle/xe`|

```
git clone https://github.com/Lentil1016/plastic-db.git

# build plastic databases
cd plastic-db/mysql-test
docker build -t mysql-test .
cd ../oracle-test
docker build -t oracle-test .

# run plastic databases
docker run \
		   --name mysql \
		   -p3306:3306 \
		   -d --rm \
		   -v /path/to/sql/file:/docker-entrypoint-initdb.d \
		   mysql-test
docker run \
		   --name oracle \
		   -p1521:1521 \
		   -it --rm \
		   -v /path/to/sql/file:/docker-entrypoint-initdb.d \
		   oracle-test

# Play with plastic databases
echo 'select version();' |mysql -uroot -h127.0.0.1 -pmysql -N -r -B;
echo 'select * from v$version;'|sqlplus -S system/oracle@127.0.0.1/xe|awk '/Linux/{print \$5}'

# delete plastic databases
docker rm -f oracle mysql
```
