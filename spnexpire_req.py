from datetime import date
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

fqdn = "https://aks-aks-aa1792-f0af8269.hcp.westeurope.azmk8s.io"

current_month = today.strftime("%b")
current_year = today.strftime("%Y")
current_day = today.strftime("%d")
day_of_year_current = datetime.now().timetuple().tm_yday  # returns 1 for January 1st
x = requests.get(fqdn, verify=False)
string = str(x.headers)
x = string.split(",")
att = x[5]
a = str(att)
b =  a.split()
expire_year = b[2]
expire_month = b[1]
expire_day = b[0]

for keys in months:
  current_month_number = months[current_month]
  expire_month_number = months[b[1]]

datetime_str = expire_day + "/" + expire_month_number + "/" + expire_year[-2:]
datetime_expire = datetime.strptime(datetime_str, '%d/%m/%y')
day_of_year_expire = datetime_expire.timetuple().tm_yday  # returns 1 for January 1st

if current_year <= expire_year and day_of_year_current <= day_of_year_expire - alert_window:
    print("Warning! SPN Will expire in ", alert_window)
else:
	print("We are good for now!")
print ("SPN will expire in ", expire_year, expire_month, expire_day)
