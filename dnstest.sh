#!/bin/bash
while true;do
  sleep $INTERVAL;
  nslookup $HOST > /dev/null 2>&1
  if [ $? -eq 1 ]
    then
        echo -n "$(date) "; echo  "Could not resolve";
    else
       echo -n "$(date) "; nslookup $HOST | grep "Address" | awk '{print $2}' | sed -n 2p;
  fi
done
