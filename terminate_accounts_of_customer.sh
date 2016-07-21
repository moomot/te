#!/bin/bash

if [[ $# != 6 ]]; then
        echo "Usage: $0 -u login -p password -a host"
        exit
fi
sid=`soap_generic.py -u $2 -p $4 -a $6 -sAccount | grep -oP "(?<=session\sid\s)\w+"`
a=`mysql -u root -e "select i_account from Accounts where i_customer in (select i_customer from Customers where bill_status = 'C') and bill_status = 'O';" porta-billing | tail -n +2`
arr=($a)
for i in ${arr[@]};
do
        soap_generic.py -u $2 -p $4 -a $6 --session-id="$sid" -sAccount -mterminate_account --param 'i_account="'$i'"'
done