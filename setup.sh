#!/bin/bash

docker network create caddy
docker compose up -d

sleep 60

####################
# set up tmi-sirtfi
####################

curl https://ta2.g100.aarc3-pilots.vm.fedcloud.eu/enroll?sub=https://tmi-sirtfi.g100.aarc3-pilots.vm.fedcloud.eu

####################
# set up rp
####################

sleep 5
docker compose restart rp
curl https://ta1.g100.aarc3-pilots.vm.fedcloud.eu/enroll?sub=https://rp.g100.aarc3-pilots.vm.fedcloud.eu
curl https://ta2.g100.aarc3-pilots.vm.fedcloud.eu/enroll?sub=https://rp.g100.aarc3-pilots.vm.fedcloud.eu

####################
# set up rp-expl
####################

docker run --rm \
  --user "$(id -u):$(id -g)" \
  -v "${PWD}/rp-expl:/conf" \
  --network caddy \
  --entrypoint python3 \
  ddgu/fedservice \
  /app/setup.py /conf

TM=`curl https://tmi-sirtfi.g100.aarc3-pilots.vm.fedcloud.eu/trustmark\?sub\=https://rp-expl.g100.aarc3-pilots.vm.fedcloud.eu\&trust_mark_type\=https://refeds.org/sirtfi`

echo "[{\"trust_mark\": \"${TM}\", \"trust_mark_type\": \"https://refeds.org/sirtfi\"}]" > rp-expl/rp/rp-expl/trust_marks

docker compose restart rp-expl

sleep 5
curl https://ta1.g100.aarc3-pilots.vm.fedcloud.eu/enroll?sub=https://rp-expl.g100.aarc3-pilots.vm.fedcloud.eu
curl https://ta2.g100.aarc3-pilots.vm.fedcloud.eu/enroll?sub=https://rp-expl.g100.aarc3-pilots.vm.fedcloud.eu

####################
# set up OP
####################

docker run --rm \
  --user "$(id -u):$(id -g)" \
  -v "${PWD}/op:/conf" \
  --network caddy \
  --entrypoint python3 \
  ddgu/fedservice \
  /app/setup.py /conf

TM=`curl https://tmi-sirtfi.g100.aarc3-pilots.vm.fedcloud.eu/trustmark\?sub\=https://op.g100.aarc3-pilots.vm.fedcloud.eu\&trust_mark_type\=https://refeds.org/sirtfi`

echo "[{\"trust_mark\": \"${TM}\", \"trust_mark_type\": \"https://refeds.org/sirtfi\"}]" > op/op/op/trust_marks

docker compose restart op

sleep 5
curl https://ta1.g100.aarc3-pilots.vm.fedcloud.eu/enroll?sub=https://op.g100.aarc3-pilots.vm.fedcloud.eu
curl https://ta2.g100.aarc3-pilots.vm.fedcloud.eu/enroll?sub=https://op.g100.aarc3-pilots.vm.fedcloud.eu
