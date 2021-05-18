# Author
Animesh Kumar Naskar
# Description: 
Script to check and notify (NOT automatic booking) the availability of Covid vaccines in Bangalore (bbmp, urban, rural) identified by district_id. 
 		Script can be modified accordingly to search for any district. The scripts has been verified on Ubuntu 20.04
# Requirement
Below utilities are required for the script to work. They can be installed using 'sudo apt install <pkg-name>' if not available
```
wget
jq
nodejs (for npm)
json2yaml (via npm install -g json2yaml)
spd-say
mailx
```
# Execution
To continously monitor run the script as below (assuming monitoring every 30 seconds):
```
while [[ "1" == "1" ]]; do ./fetchava.sh ; sleep 30; done
```
# Bugs
Code still not perfect. Parameters can keep changing. Report any issues to animesh303@gmail.com

