# Credits go to Andrew Griffiths

@echo off
set datapath=c:\data
ECHO These commands will enable tracing:
@echo on
mkdir %datapath%
ipconfig /displaydns > %datapath%\dnscache.txt
ipconfig /flushdns
::%datapath%\procdump.exe -ma -i %datapath% --accepteula
tasklist /svc > %datapath%\start-tasklist.txt
netsh trace start capture=yes maxsize=4096 tracefile=%datapath%\nettrace.etl
logman create trace "win_dns_client" -ow -o %datapath%\win_dns_client.etl -p {1C95126E-7EEA-49A9-A3FE-A378B03DDB4D} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets
logman create trace "dns_trace" -ow -o %datapath%\dns_trace.etl -p {1540FF4C-3FD7-4BBA-9938-1D1BF31573A7} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets
logman create trace "win_net_dns" -ow -o %datapath%\win_net_dns.etl -p {9CA335ED-C0A6-4B4D-B084-9C9B5143AFF0} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets
logman create trace "dns_api" -ow -o %datapath%\dns_api.etl -p {609151DD-04F5-4DA7-974C-FC6947EAA323} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets
logman create trace "ctlguid" -ow -o %datapath%\ctlguid.etl -p {563A50D8-3536-4C8A-A361-B37AF04094EC} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets
logman create trace "ctlguid2" -ow -o %datapath%\ctlguid2.etl -p {76325CAB-83BD-449E-AD45-A6D35F26BFAE} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets
logman create trace "dns_res" -ow -o %datapath%\dnsres.etl -p {F230B1D5-7DFD-4DA7-A3A3-7E87B4B00EBF} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets
logman create trace "ctlguid3" -ow -o %datapath%\ctlguid3.etl -p {A7B8B859-D00E-45CC-85B8-89EA5D015C62} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets
netstat -abno > %datapath%\netstat_start.txt
@echo off
echo
ECHO Reproduce your issue and enter any key to stop tracing
@echo on
pause
logman stop "win_dns_client" -ets
logman stop "dns_trace" -ets
logman stop "win_net_dns" -ets
logman stop "dns_api" -ets
logman stop "ctlguid" -ets
logman stop "ctlguid2" -ets
logman stop "dns_res" -ets
logman stop "ctlguid3" -ets
wevtutil epl Application %datapath%\Application.evtx
wevtutil epl System %datapath%\System.evtx
netsh trace stop
tasklist /svc > %datapath%\stop-tasklist.txt
netstat -abno > %datapath%\netstat_after.txt
::%datapath%\procdump.exe -u
@echo off
echo Tracing has been captured and saved successfully at %datapath%
pause
