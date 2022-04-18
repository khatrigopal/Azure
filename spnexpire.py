import requests
import os
import subprocess
from datetime import datetime
from subprocess import Popen, PIPE
import sys

alert_window = 90

months = {

   "Jan": "1",
   "Feb": "2",
   "Mar": "3",
   "Apr": "4",
   "May": "5",
   "Jun": "6",
   "Jul": "7",
   "Aug": "8",
   "Sep": "9",
   "Oct": "10",
   "Nov": "11",
   "Dec": "12"
}


today = date.today()

#d4 = today.strftime("%b-%d-%Y")
current_month = today.strftime("%b")
current_year = today.strftime("%Y")
current_day = today.strftime("%d")
#print("Current day of the Year : ", current_day)
#print("d4 =", d4)

day_of_year_current = datetime.now().timetuple().tm_yday  # returns 1 for January 1st
print("Current day of the Year: ", day_of_year_current)

commands = '''
curl -k https://aks-aks-aa1792-f0af8269.hcp.westeurope.azmk8s.io -k -v 2>&1 | grep expire
'''

process = subprocess.Popen('/bin/bash', stdin=subprocess.PIPE, stdout=subprocess.PIPE)
body, err = process.communicate(commands.encode('utf-8'))
a = str(body)
b =  a.split()
expire_year = b[6]
expire_month = b[3]
expire_day = b[4]
#print(b[0])
#print("Aici", b[3])
#print("Day",b[4])
#print(b[6])
#x = datetime.datetime.now()
#print(x.year)
#print(x.strftime("%A"))
for keys in months:
  current_month_number = months[current_month]
  expire_month_number = months[b[3]]
#print(current_month_number)
#print(expire_month_number)

datetime_str = expire_day + "/" + expire_month_number + "/" + expire_year[-2:]
#print(datetime_str)
#datetime_str = '09/19/18 13:55:26'
datetime_expire = datetime.strptime(datetime_str, '%d/%m/%y')
day_of_year_expire = datetime_expire.timetuple().tm_yday  # returns 1 for January 1st
print("Day of the Year - Expire", day_of_year_expire)

#datetime_object = datetime.strptime(datetime_str, '%m/%d/%y %H:%M:%S')
#warning_time = int(expire_day) - 10
if current_year <= expire_year and day_of_year_current <= day_of_year_expire - alert_window:
    print("Atemtie")


print ("SPN will expire in ", expire_year, expire_month, expire_day)
