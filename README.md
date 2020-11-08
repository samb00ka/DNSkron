## About DNSkron

DNSkron is a Linux shell script developed to enumerate historical DNS records, subdomains, analyze network infrastructure and find potentially related websites for a target domain or IP address. In some situations helps to disclosure Cloudflare protected websites. The script uses Virustotal API free key.

#### Requirements

DNSkron requires curl, csvtool, jq

```sh
$ sudo apt install curl csvtool jq
```
#### Installation

1. Register a Virustotal account and get your free API key
2. Download dnskron.sh to your Linux PC and put it into a folder
3. Install requirements
4. Open dnskron.sh with a text editor, replace <API_KEY> with your API key and save the file

#### Usage

Open Terminal in a folder where the script is located and type the following (root rights are not required):
```sh
$ bash dnskron.sh
```
Example:

- For a target domain "free-mp3-radio.fm" we will create a "free-mp3-radio" case and use key words "mp3, radio, fm, music", they will help us to find related domains (can be operated by the same owner). 

In addition to stdout output the script creates a folder with a csv file with all IP addresses found and a txt file with subdomains and IP related information. Timestamp shows when domain was seen on IP for the last time.

API limit is enough for a non-commercial daily use. The script was tested on Ubuntu/Debian systems.

#### Special thanks to Virustotal: Guys you are doing a great job!!!

#### Screenshots

![N|Solid](https://github.com/samb00ka/DNSkron/blob/main/Screenshot-1.png)
![N|Solid](https://github.com/samb00ka/DNSkron/blob/main/Screenshot-2.png)
![N|Solid](https://github.com/samb00ka/DNSkron/blob/main/Screenshot-3.png)
