#!/bin/bash
# vim: set sw=4 sts=4 et foldmethod=indent :

sed -i \
    -e 's/[|\n]/##/g'\
    -e ':a;N;$!ba;s/\n/\ /g'\
    -e 's/##/\n/g'\
    -e 's/#\$#/\$/g'\
    $1
