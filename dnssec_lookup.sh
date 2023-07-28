#!/bin/bash
############
##
##   Script:            get_dnssec.sh
##   Version:           v0.01
##   Description:       Simple bashscript to fetch the DNS-SEC records from an nameserver
##   Created by:        Sander Jeurissen
##   Created on:        27-7-2023
##   Copyright:         Sander Jeurissen (c) 2023
##   License:           This project is licensed under the terms of the MIT license.
##   Source:            https://github.com/sanderjeurissen/dnssec_lookup/
##
############

## SETTING ##

NS=127.0.0.1

## Read input for domain ##

if [ -z "$1" ]
        then
    read -p "Enter domain: " DOMAIN
else
    DOMAIN=$1
fi

## Get DNS records ##

DIG=$(dig $DOMAIN @$NS DNSKEY  +short)
FULLDIG=$(dig $DOMAIN @$NS DNSKEY  +multiline)

## Get algorithm ##

ALGO_LIST="
RSA-SHA1 (5)
RSA-SHA1-NSEC3 (7)
RSA-SHA256 (8)
RSA-SHA512 (10)
ECDSA Curce P-256 with SHA-256 (13)
ECDSA Curce P-256 with SHA-384 (14)
Ed25519 Curve (15)
Ed448 Curve (16)"

ALGO_NUM=$(echo "$DIG" | grep 256 | cut -c7-8 | head -n1)
ALGO_1="($ALGO_NUM"
ALGO_NAME=$(echo "$ALGO_LIST" | grep $ALGO_1)

## Get ID's ##

KSK_ID=$(echo "$FULLDIG" | grep KSK | sed -n 's/.*key id = //p')
ZSK_ID=$(echo "$FULLDIG" | grep ZSK | sed -n 's/.*key id = //p')

## Get keys ##

KSK_KEY=$(echo "$DIG" | grep 257 | sed 's/257 3 7 //g' | sed 's/ //g' )
ZSK_KEY=$(echo "$DIG" | grep 256 | sed 's/256 3 7 //g' | sed 's/ //g' )

## Error handling ##

# Result check
if [ -z "$KSK_KEY" ]
then
        echo "Error !"
        echo "No DNS-SEC record found."
        exit 1;
fi

# ZSK-check
ZSK_NUM=$(echo "$FULLDIG" | grep ZSK | sed -n 's/.*key id = //p'| wc -l)
if [[ $ZSK_NUM -gt 1 ]]
then
        echo "Error !"
        echo "Multiple ZSK-records detected."
        exit 1;
fi

# KSK-check
KSK_NUM=$(echo "$FULLDIG" | grep KSK | sed -n 's/.*key id = //p'| wc -l)
if [[ $KSK_NUM -gt 1 ]]
then
        echo "Error !"
        echo "Multiple KSK-records detected."
        exit 1;
fi


## Display output ##

clear
echo "DNS-SEC keys for $DOMAIN"
echo ""
echo -e "Algorithm: \t $ALGO_NAME"
echo ""
echo -e "KSK: \t\t $KSK_ID"
echo ""
echo "$KSK_KEY"
echo ""
echo -e "ZSK: \t\t $ZSK_ID"
echo ""
echo "$ZSK_KEY"
echo ""
