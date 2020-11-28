# DNSkron - DNS history recon tool
# Version: 1.0
# Date: 2020-Nov-07
# Author: s@mb00ka (s7mb00ka@gmail.com)


api_key=API_KEY

mkdir cases > /dev/null 2>&1

time=$(date -u +'%F_%T')

key_words_lookup(){

echo

echo -e "\e[31mRelated domains based on key words '$key_word_1, $key_word_2, $key_word_3, $key_word_4':\e[0m"

echo 

grep -i -e "$key_word_1" -e "$key_word_2" -e "$key_word_3" -e "$key_word_4" log.csv | sort | uniq | sed 's/,/\t/g' > keywords.txt

if [ -s "keywords.txt" ]; then

    cat keywords.txt

else

    echo "No matches found."

fi

cat log.csv | sort | uniq > $target-report-$time.csv

mkdir cases/$case_name/$target > /dev/null 2>&1

mv $target-report-$time.csv cases/$case_name/$target/

mv $target-summary-$time.txt cases/$case_name/$target/

rm display.csv ip.csv domain.csv domain-report.txt subdomains.csv log.csv keywords.txt ip-log.csv subdomain.csv subdomain-report.txt > /dev/null 2>&1

echo

echo "Done! Report has been saved to /cases/$case_name/$target"

echo

}

summary_report(){

echo

echo -e "\e[31mSummary Report for $target:\e[0m"

echo

cat $target-summary-$time.txt

key_words_lookup

}

ip_lookup(){

for ip in $(cat ip.csv); do

	url_ip=$(echo "https://www.virustotal.com/vtapi/v2/ip-address/report?apikey=$api_key&ip=$ip")

	curl -s --request GET \
	  --url "$url_ip" > ip-report.txt

	asn=$(cat ip-report.txt | jq '.asn' | tr -d '''"''')

	as=$(cat ip-report.txt | jq '.as_owner' | tr -d '''"''')

	cat ip-report.txt | jq '.resolutions[].hostname' | tr -d '''"''' > hostname.csv

	cat ip-report.txt | jq '.resolutions[].last_resolved' | tr -d '''"''' > res_date.csv

	curl -s https://ipinfo.io/$ip > geoip.txt
		
	country=$(cat geoip.txt | jq '.country' | tr -d '''"''')
		
	hostname=$(cat geoip.txt | jq '.hostname' | tr -d '''"''')
		
	org=$(cat geoip.txt | jq '.org' | tr -d '''"''')
	
	echo
		
	echo "$ip resolves to $hostname ($org, $country)"
	 
	sleep 3

	echo

	counter_ip=$(wc -l hostname.csv | cut -d " " -f 1)

	seq $counter_ip | sed "c $ip" > ip-list.csv

	csvtool paste ip-list.csv res_date.csv hostname.csv > display.csv

	csvtool paste ip-list.csv res_date.csv hostname.csv >> log.csv

	echo -e "\e[31mDomains($counter_ip) for $ip:\e[0m"

	echo "$ip | $asn | $as | $country | $counter_ip domains" >> $target-summary-$time.txt

	echo

	cat display.csv | sort | sed 's/,/\t/g'

	rm geoip.txt display.txt hostname.csv ip-list.csv ip-report.txt res_date.csv > /dev/null 2>&1

	sleep 20

done

}

subdomain_lookup(){

for subdomain in $(cat subdomains.csv); do

	url_subdomain=$(echo "https://www.virustotal.com/vtapi/v2/domain/report?apikey=$api_key&domain=$subdomain")

	curl -s --request GET \
	  	--url "$url_subdomain" > subdomain-report.txt
	  
	cat subdomain-report.txt | jq '.resolutions[].last_resolved' | tr -d '''"''' > res_date.csv

	cat subdomain-report.txt | jq '.resolutions[].ip_address' | tr -d '''"''' > ip.csv

	counter_subdomain=$(wc -l ip.csv | cut -d " " -f 1)

	seq $counter_subdomain | sed "c $subdomain" > subdomain.csv

	cat ip.csv >> ip-log.csv

	csvtool paste res_date.csv ip.csv > display.csv

	echo -e "\e[31mIP($counter_subdomain) for $subdomain:\e[0m"

	echo

	cat display.csv | sort | sed 's/,/\t/g'

	echo

	sleep 20

done

cat ip-log.csv | sort | uniq > ip.csv

counter_subdomain_1=$(wc -l ip.csv | cut -d " " -f 1)

echo -e "\e[31m$target has $counter_subdomain_1 unique IP(s) in connection:\e[0m"

echo

cat ip.csv

echo

echo "Checking IP(s)..."

ip_lookup

}

target_domain_lookup(){

echo

read -p "Target Domain > " target
read -p "Case > " case

case_name=$(echo $case | sed 's/ /_/g')

echo

read -p "Key Word 1/4 > " key_word_1
read -p "Key Word 2/4 > " key_word_2
read -p "Key Word 3/4 > " key_word_3
read -p "Key Word 4/4 > " key_word_4

echo

if [ ! -d cases/$case_name ]; then

    mkdir cases/$case_name

    echo "Case folder has been created."
    
    echo

fi


url=$(echo "https://www.virustotal.com/vtapi/v2/domain/report?apikey=$api_key&domain=$target")

curl -s --request GET \
  --url "$url" > domain-report.txt
  
domain_check=$(grep -i "domain not found" domain-report.txt)

if [ "$domain_check" ]; then

	echo

	echo -e "\e[31mDomain not found or wrong domain! Please double check and try again.\e[0m"
	
	echo
	
	exit
 
else
  
	cat domain-report.txt | jq '.resolutions[].last_resolved' | tr -d '''"''' > res_date.csv

	cat domain-report.txt | jq '.resolutions[].ip_address' | tr -d '''"''' > ip.csv
	
	counter=$(wc -l ip.csv | cut -d" " -f1)

	seq $counter | sed "c $target" > domain.csv

	csvtool paste res_date.csv ip.csv > display.csv
	
	cat ip.csv > ip-log.csv

	echo -e "\e[31mIP($counter) for $target:\e[0m"

	echo

	cat display.csv | sort | sed 's/,/\t/g'

	echo

	sleep 3

	cat domain-report.txt | jq '.subdomains' | tr -d '''[],"''' | sed 's/^[ \t]*//' | sed '/^$/d' | grep -v "null" | sort > subdomains.csv

	if [ -s subdomains.csv ]; then

		counter1=$(wc -l subdomains.csv | cut -d " " -f 1)

		seq $counter1 | sed "c $target" > domain.csv

		cat subdomains.csv > $target-summary-$time.txt
		
		echo >> $target-summary-$time.txt

		echo -e "\e[31mSubdomains($counter1) for $target:\e[0m"

		echo

		cat subdomains.csv

		echo

		subdomain_lookup
		
	else

		echo "No subdomains found. Checking IP(s)..."
		
		cat ip-log.csv | sort | uniq > ip.csv

		ip_lookup

	fi

	sleep 3

fi

}

target_ip_lookup(){

echo

read -p "Target IP > " target
read -p "Case > " case_name

case_name=$(echo $case | sed 's/ /_/g')

echo

read -p "Key Word 1/4 > " key_word_1
read -p "Key Word 2/4 > " key_word_2
read -p "Key Word 3/4 > " key_word_3
read -p "Key Word 4/4 > " key_word_4

if [ ! -d cases/$case_name ]; then

    mkdir cases/$case_name

    echo "Case folder has been created."

fi

echo "$target" > ip.csv

ip_lookup

}

clear

echo "============ DNSkron ============="
echo "===== DNS HISTORY RECON TOOL ====="
echo "========== by s@mb00ka ==========="

echo "
Please select a task:

1. Domain lookup
2. IP lookup
0. Quit
"

read -p "Enter selection [0-2] > "
if [[ $REPLY =~ ^[0-2]$ ]]; then
	if [[ $REPLY == 0 ]]; then
		echo "Program terminated."
		exit
	fi
	if [[ $REPLY == 1 ]]; then
		target_domain_lookup
		summary_report
	fi
	if [[ $REPLY == 2 ]]; then
		target_ip_lookup
		key_words_lookup
	fi
fi
