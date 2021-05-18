########################################################################################################################################################################
# Author: Animesh Kumar Naskar
# Description: Script to check and notify (NOT automatic booking) the availability of Covid vaccines in Bangalore (bbmp, urban, rural) identified by district_id. 
# 		Script can be modified accordingly to search for any district. The scripts has been verified on Ubuntu 20.04
# Requirement: Below utilities are required for the script to work. They can be installed using 'sudo apt install <pkg-name>' if not available
#		wget
#		jq
# 		nodejs (for npm)
#		json2yaml (via npm install -g json2yaml)
#		spd-say
# Execution: To continously monitor run the script as below (assuming monitoring every 30 seconds):
#		while [[ "1" == "1" ]]; do ./fetchava.sh ; sleep 30; done
# Bugs: Code still not perfect. Parameters can keep changing. Report any issues to animesh303@gmail.com
########################################################################################################################################################################

# Email Ids for notification (comma separated)
notice="xxxx@xxxx.xxx"

# Define age limit. ** Should be changed with global search and replace for the value.  **
agelimit=18


userdata="Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:88.0) Gecko/20100101 Firefox/88.0"
dt=$(date +"%d-%m-%Y")
dt_st=$(date +"%d-%m-%Y %T")


echo -n " Checking at $dt_st ... "

# District Ids for Bangalore region:
# 	bbmp_district_id=294
# 	rural_district_id=276
# 	urban_district_id=265

for area in 294 276 265
do
	vacreport=vacavailable-${area}
	apiurl="https://cdn-api.co-vin.in/api/v2/appointment/sessions/calendarByDistrict?district_id=${area}&date=${dt}"
	
	# Age limit **should** be manually changed here as well.
	# Modify the available capacity to reduce noise
	wget -cq  -U ${userdata} ${apiurl} -O - | jq '.centers[] | select(.sessions[] | (.available_capacity > 0) and (.min_age_limit == 18))' | sed -z 's/}\n{/},\n{/g' > ${vacreport}.tmp
	echo "]" >> ${vacreport}.tmp 
	sed  -i '1i [' ${vacreport}.tmp
	
	# Choose one of the below 2 statements for level of details required in notificaton
	jq 'map(del(.center_id, .state_name, .district_name, .block_name, .lat, .long, .to, .from, .fee_type, .sessions[].slots, .sessions[].session_id)) ' ${vacreport}.tmp > ${vacreport}.json
	#jq 'map(del(.center_id, .state_name, .district_name, .block_name, .lat, .long, .to, .from, .fee_type, .vaccine_fees, .sessions)) ' ${vacreport}.tmp > ${vacreport}.json
	
	json2yaml ./${vacreport}.json > ./${vacreport}.yaml
	words=$(wc -w vacavailable-294.yaml | cut -c1)

done


found=$(cat *.yaml | grep -v "-" | wc -l)

if [[ "$found" != "3" ]];
then
	# Choose one of audio notification based on available utility. For the 1st command, sample speech.wav has been included
	#aplay speech.wav
	spd-say "Covid vaccine found"
	
	echo "BBMP >>>>>>>>" 
	cat vacavailable-294.yaml
	echo "Rural >>>>>>>>"
	cat vacavailable-276.yaml
	echo "Urban >>>>>>>>"
	cat vacavailable-265.yaml
	
	# Disable below 3 lines. if email client is not configured. Ref https://vitux.com/how-to-use-gmail-from-the-ubuntu-terminal-to-send-emails for Gmail config.  Note: Disable unsecured app access from Google account security settings for make it work (but not recommended due to security reasons). 
	echo "Emailing .. "
	cat *.yaml | mailx -s "[Age:$agelimit] Covid Vaccine found at $dt_st" "$notice" 
	echo "Done"

else
	echo "Sorry none found!"

fi


# Cleanup
rm *.tmp *.json


