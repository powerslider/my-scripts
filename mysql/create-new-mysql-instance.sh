#!/bin/bash
# vim: set sw=4 sts=4 et foldmethod=indent :

NEW_INSTANCE_NAME="mysql-$1"
NEW_MYSQLD="mysqld-$1"
PORT=$2

if [ $# -eq 0 ]
  then
    echo "No arguments supplied. Please supply instance name and port number!"
    exit
fi

mkdir /var/lib/$NEW_INSTANCE_NAME
chown -R mysql:mysql /var/lib/$NEW_INSTANCE_NAME/
echo "Created new datadir /var/lib/$NEW_INSTANCE_NAME"

mkdir /var/log/$NEW_INSTANCE_NAME
chown -R mysql:mysql /var/log/$NEW_INSTANCE_NAME

cp -R /etc/mysql/ /etc/$NEW_INSTANCE_NAME
echo "Copied standard config layout from /etc/mysql/ to /etc/$NEW_INSTANCE_NAME"

cd /etc/$NEW_INSTANCE_NAME
sed -i "s/3306/$PORT/g" my.cnf
sed -i "s/mysqld.sock/$NEW_MYSQLD.sock/g" my.cnf
sed -i "s/mysqld.pid/$NEW_MYSQLD.pid/g" my.cnf
sed -i "s/var\/lib\/mysql/var\/lib\/$NEW_INSTANCE_NAME/g" my.cnf
sed -i "s/var\/log\/mysql/var\/log\/$NEW_INSTANCE_NAME/g" my.cnf
echo "Done editing new my.cnf at /etc/$NEW_INSTANCE_NAME/my.cnf"

echo "Disable apparmor..."
ln -s /etc/apparmor.d/usr.sbin.mysqld /etc/apparmor.d/disable/
apparmor_parser -R /etc/apparmor.d/usr.sbin.mysqld

echo "Installing new instance -> $NEW_INSTANCE_NAME..."
mysql_install_db --user=mysql --datadir=/var/lib/$NEW_INSTANCE_NAME/
echo "New instance is already installed!"

read -p "Would you like to start your new mysql instance -> $NEW_INSTANCE_NAME (y/n)?" choice
case "$choice" in
        y|Y ) mysqld_safe --defaults-file=/etc/$NEW_INSTANCE_NAME/my.cnf &;;
        n|N ) echo Start terminated. You would have to start it manually!;;
        *) echo Invalid input, try again!;;
esac
