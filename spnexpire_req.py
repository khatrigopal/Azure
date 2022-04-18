#curl -k https://aks-aks-aa1792-eadf40b6.hcp.westeurope.azmk8s.io -k -v 2>&1 | grep expirecurl
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

x = requests.get('https://aks-aks-aa1792-f0af8269.hcp.westeurope.azmk8s.io', verify=False)
#print(x.headers)
string = str(x.headers)
print(string)
x = string.split(",")
att = x[5]
#print("--->",att)

###a = str(body)
a = str(att)
#print("AlA",a)
