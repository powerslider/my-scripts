#!/bin/bash
# vim: set sw=4 sts=4 et foldmethod=indent :

USER=$1
PASSWORD=$2
PORT=$3

mysqladmin -u$USER -p$PASSWORD -P$PORT extended -r -i 10 | grep Handler_read_rnd_next
