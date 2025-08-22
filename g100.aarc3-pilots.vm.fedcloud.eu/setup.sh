#!/bin/bash

docker network create caddy
docker compose up -d

docker run --rm \
  --user "$(id -u):$(id -g)" \
  -v "${PWD}/rp-expl:/conf" \
  --network caddy \
  --entrypoint python3 \
  ddgu/fedservice \
  /app/setup.py /conf

curl https://ta2.g100.aarc3-pilots.vm.fedcloud.eu/enroll?sub=https://tmi-sirtfi.g100.aarc3-pilots.vm.fedcloud.eu

curl https://ta1.g100.aarc3-pilots.vm.fedcloud.eu/enroll?sub=https://rp.g100.aarc3-pilots.vm.fedcloud.eu
curl https://ta2.g100.aarc3-pilots.vm.fedcloud.eu/enroll?sub=https://rp.g100.aarc3-pilots.vm.fedcloud.eu

curl https://ta1.g100.aarc3-pilots.vm.fedcloud.eu/enroll?sub=https://rp-expl.g100.aarc3-pilots.vm.fedcloud.eu
curl https://ta2.g100.aarc3-pilots.vm.fedcloud.eu/enroll?sub=https://rp-expl.g100.aarc3-pilots.vm.fedcloud.eu
