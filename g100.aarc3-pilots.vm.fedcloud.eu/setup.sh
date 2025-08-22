#!/bin/bash

# setup the fedservice rp
# TAs must be running before this script

docker compose up ta1 ta2 caddy -d

docker run --rm \
  --user "$(id -u):$(id -g)" \
  -v "${PWD}/rp-expl:/conf" \
  --network caddy \
  --entrypoint python3 \
  ddgu/fedservice \
  "/app/setup.py /conf"

docker-compose up tmi-sirtfi -d
curl https://ta2.g100.aarc3-pilots.vm.fedcloud.eu/enroll?sub=https://tmi-sirtfi.g100.aarc3-pilots.vm.fedcloud.eu

docker-compose up rp -d
curl https://ta1.g100.aarc3-pilots.vm.fedcloud.eu/enroll?sub=https://rp.g100.aarc3-pilots.vm.fedcloud.eu
curl https://ta2.g100.aarc3-pilots.vm.fedcloud.eu/enroll?sub=https://rp.g100.aarc3-pilots.vm.fedcloud.eu

docker compose up rp-expl -d
curl https://ta1.g100.aarc3-pilots.vm.fedcloud.eu/enroll?sub=https://rp-expl.g100.aarc3-pilots.vm.fedcloud.eu
curl https://ta2.g100.aarc3-pilots.vm.fedcloud.eu/enroll?sub=https://rp-expl.g100.aarc3-pilots.vm.fedcloud.eu