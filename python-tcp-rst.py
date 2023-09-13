import socket
import struct
import time

def client(host, port):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM, 0)
    s.connect((host, port))
    l_onoff = 1

    l_linger = 0

    time.sleep(1)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_LINGER, struct.pack('ii', l_onoff, l_linger))
    # send data here
    s.close()
if __name__ == "__main__":
   iteration = 0
   while True:
     iteration = iteration + 1
     client("8.8.8.8", 443)
     print("Iteration " + str(iteration))
     time.sleep(0.2)
