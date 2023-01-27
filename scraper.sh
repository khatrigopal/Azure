#!/bin/bash

read -p "Please enter  filename: " fileName
read -p "Please enter since TimeStamp (Ex. 2022-01-11 03:00): " sinceTime
echo $sinceTime
read -p "Please enter until TimeStamp (Ex. 2022-02-11 03:00): " untilTime
echo $untilTime
echo "Unzip the IaasDisk Archive"
unzip $fileName
echo "---- Number of VM Boots ----"
journalctl -D ./device_0/var/log/journal --list-boots
echo
echo "---- Journalctl Logs on a specified timeframe ----"
journalctl -D ./device_0/var/log/journal --since "$sinceTime" --until "$untilTime"
echo

read -p "Do you want to search for a term in Pod's logs? (y/n): " searchTerm
if [ $searchTerm == "y" ]  
then 
  read -p "Search for a term in Pods" term
  grep -r $term ./device_0/var/log/pods/
else
  exit
fi 

read -p "Do you want to extract Journalctl on units? (y/n): " searchTerm
if [ $searchTerm == "y" ]
then
  echo "Extracting full Journalctl logs"
  journalctl -D ./device_0/var/log/journal --no-page > ./journalctl_complete.txt
  echo "Extracting  Journalctl containerd logs"
  journalctl -D ./device_0/var/log/journal -u containerd --no-page > ./journalctl_containerd.txt
  echo "Extracting Journalctl cloud-init logs "
  journalctl -D ./device_0/var/log/journal -u cloud-init --no-page > ./journalctl_cloud_init.txt
  echo "Extracting Journalctl kubelet logs "
  journalctl -D ./device_0/var/log/journal -u cloud-init --no-page > ./journalctl_kubelet.txt
else
  exit
fi

read -p "Do you want so search for term occurence in logs? (y/n): " searchTerm
if [ $searchTerm == "y" ]
then
  input="./codes.txt"
  cat ./signatures.asc | while IFS= read -r line;
  do
    echo "$line";
    RESULT=$(grep -i "${line}" journalctl_complete.txt | wc -l);
    grep -i "${line} ./report_journal_complete";
    echo "${RESULT}"
done
fi
#done 
