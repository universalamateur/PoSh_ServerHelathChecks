# PoSh_ServerHelathChecks
Collection of PowerShell Scripts to use in a windows server environment for sysadmin tasks

## Free Space on Harddisks Server Check Script
With this script the admin can from preferable the DC check the diskspace on the servers in the same domain, which are listed in a txt file in the same folder as the script

The Script takes all the servers in the text file "servers.txt" in the same folder and checks if those are Online.
If a server is Online, his hostname will be given out, additionally the Freedisk space and capacity of every harddisk in GB.
This data will be given in the console and in a *.csv file, for every disk of every host one line with the parameters Server, IPAddress, Drive, Freespace, Size

In the "servers.txt" the servers for the domain have to be listed with their DNS hostname as hostname or as FQDN.
Lines with a # at the start will be ignored.
Every Host has to stand alone in one line.
Example for host entry:
HVHOST1.ad.mediastrom.gr
HVHOST2

If the script is executed not as a domain Admin, there have to be done two chances.
Line 14 and 32 have to ununcommented to ask for the credentilas of every server
