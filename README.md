# covid
Covid monitor infra

# Keypair
ssh-keygen -q -t rsa -C "awskey" -N '' -f ~/.ssh/awskey <<<y 2>&1 >/dev/null
aws ec2 import-key-pair --key-name "ec2kp" --public-key-material fileb://~/.ssh/awskey.pub

# Environment variables


aws cloudformation create-stack --stack-name covidstk --template-body file://src/infra.yml
aws cloudformation wait stack-create-complete --stack-name covidstk

aws cloudformation delete-stack --stack-name covidstk
aws cloudformation wait stack-delete-complete --stack-name covidstk


aws cloudformation update-stack --stack-name covidstk --template-body file://src/infra.yml && aws cloudformation wait stack-update-complete --stack-name covidstk

aws cloudformation describe-stack-resources --stack-name covidstk --output yaml-stream
export ec2PublicDNS=$(aws cloudformation describe-stacks --stack-name covidstk | jq '.Stacks[0].Outputs[] | select(.OutputKey=="ec2PublicDNS")' | grep OutputValue | tr -d ' ' | tr -d '"' | tr -d ',' | cut -d: -f2)


# Connect

ssh -i "~/.ssh/awskey" ubuntu@${ec2PublicDNS}


# Scribble

https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByDistrict?district_id=294&date=09-05-2021

wget -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:88.0) Gecko/20100101 Firefox/88.0" "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByDistrict?district_id=294&date=09-05-2021"  


wget -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:88.0) Gecko/20100101 Firefox/88.0" --referer "https://www.cowin.gov.in/" "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByDistrict?district_id=294&date=09-05-2021"  

Host: cdn-api.co-vin.in
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:88.0) Gecko/20100101 Firefox/88.0
Accept: application/json, text/plain, */*
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate, br
Origin: https://www.cowin.gov.in
Connection: keep-alive
Referer: https://www.cowin.gov.in/

  212  jq .centers abc.json | jq -c '.[] | select(.genre | contains("house"))'
  213  jq .centers abc.json | jq -c '.[] | select(.sessions | contains("house"))'
  214  jq .centers abc.json | jq -c '.[]'
  215  jq .centers abc.json
  216  jq .centers abc.json > abc2.json
  217  cat abc.json | jq '.centers'
  218  cat abc.json | jq '.centers | select(pincode | contains("560066"))'

  jq '.centers abc.json | select (pincode)'

  cat abc.json  | jq .centers | jq '.[] | select(.available_capacity==10)'

  cat abc.json  | jq .centers | jq '.[] | select(.sessions[].available_capacity==10)'

  cat abc.json  | jq .centers | jq '.[] | select((.sessions[].available_capacity > 0) and (.sessions[].min_age_limit == 18))'

wget -cq  -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:88.0) Gecko/20100101 Firefox/88.0" "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByDistrict?district_id=294&date=09-05-2021"  -O - | jq .centers | jq '.[] | select((.sessions[].available_capacity > 0) and (.sessions[].min_age_limit == 18))' > vacavailable.txt

python -c 'import json; import yaml; print(yaml.dump(json.load(open("abc.json"))))'