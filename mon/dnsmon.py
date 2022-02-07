import socket
import time
import datetime

fqdn = "wdfdsfww.microsoft.com"
delays = 15
current_time = datetime.datetime.now()
if __name__ == "main":
  print("Executing script:")

while True:
  try:
    ip_add = socket.gethostbyname(fqdn)
    print(ip_add)
  except socket.gaierror as e:
    print("Error")
    with open ("error.log", "a") as file:
       file.write(str(current_time) + "---" + str(e) + "\n")
       print(e)
       file.close()
  time.sleep(delays)
