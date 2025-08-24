# Pilot infrastructure for AARC-G100 Pilot

This repository contains the infrastructure code for the AARC-G100 Pilot project. It includes Docker configurations and setup scripts to deploy the necessary services.

The main components are:

- A Trust Authority for the basic trust model (G100.1), based on [Lighthouse](https://go-oidfed.github.io/lighthouse): ta1
- A Trust Authority for the fine-grained trust model (G100.2), based on [Lighthouse](https://go-oidfed.github.io/lighthouse): ta2
- A Relying Party with automatic client registration support, based on [offa](https://go-oidfed.github.io/offa): rp
- A Relying Party with explicit client registration support, based on [fedservice](https://github.com/dianagudu/fedservice_docker): rp-expl
- An OpenID Provider, based on [fedservice](https://github.com/dianagudu/fedservice_docker): op
- A Trust Mark Issuer for Sirtfi, based on [Lighthouse](https://go-oidfed.github.io/lighthouse): tmi-sirtfi
  - Note: tmi-sirtfi is only used in the fine-grained trust model (G100.2)
  - Issues the following Trust Marks:
    - <https://refeds.org/sirtfi>
    - <https://refeds.org/sirtfi2>

Infrastructure for basic model:

```text
          +-----+
          | ta1 |
          +-----+
             │
  ┌──────────┬──────────┐
  │          │          │
+----+  +---------+  +----+
| rp |  | rp-expl |  | op |
+----+  +---------+  +----+

```

Infrastructure for fine-grained model:

```text
               +-----+
               | ta2 |
               +-----+
                  │
      ┌───────────┬──────────┬──────────┐
      │           │          │          │
+------------+  +----+  +---------+  +----+
| tmi-sirtfi |  | rp |  | rp-expl |  | op |
+------------+  +----+  +---------+  +----+

```

## Instructions for pilot participants

Requirements:

- Basic trust model (G100.1):
  - Publish OID-Fed entity configuration at `/.well-known/openid-federation` containing at least metadata for openid_provider and openid_relying_party
  - Include ta1's entity id in the list of trusted authorities: <https://ta1.g100.aarc3-pilots.vm.fedcloud.eu>
  - Capability to build and validate trust chains or use an external resolver, such as the one provided by [ta1](https://ta1.g100.aarc3-pilots.vm.fedcloud.eu/resolve)
  - Support both automatic and explicit client registration when acting as openid_provider
  - Support at least one type of client registration when acting as openid_relying_party

- Fine-grained trust model (G100.2):

Steps:

- make sure your proxy satisfies the requirements above
- send us an email requesting to participate in the pilot to [email](mailto:)
- the email should contain:
  - your Proxy's entity id
  - which trust model you want to participate in (G100.1 or G100.2)
- test the following scenarios, depending on the trust model you chose and the client registration methods supported by your proxy

G100.1:

1. Proxy as OP, rp as RP with automatic client registration

    - login at <https://whoami.g100.aarc3-pilots.vm.fedcloud.eu> using an account from your Proxy

2. Proxy as OP, rp-expl as RP with explicit client registration

    - login at <https://rp-expl.g100.aarc3-pilots.vm.fedcloud.eu> using an account from your Proxy

3. Proxy as RP with automatic client registration, op as OP

    - log in at your proxy's RP endpoint, using an account from the OP at <https://op.g100.aarc3-pilots.vm.fedcloud.eu> (testuser:testpass)

4. Proxy as RP with explicit client registration, op as OP

    - log in at your proxy's RP endpoint, using an account from the OP at <https://op.g100.aarc3-pilots.vm.fedcloud.eu> (testuser:testpass)

G100.2:

You can go through the same scenarios as in G100.1, but with additional checks at your proxy of the Sirtfi Trust Marks in the OP's and RP's entity configurations. Either one of the following Trust Marks should be present, issued by a Trust mark issuer trusted by the ta2 trust authority:

- <https://refeds.org/sirtfi>
- <https://refeds.org/sirtfi2>

## Instructions for pilot administrators

### Setup Instructions

The test infrastructure is already running at [g100.aarc3-pilots.vm.fedcloud.eu](http://g100.aarc3-pilots.vm.fedcloud.eu). It was set up using the following steps:

- run the setup script: `./setup.sh`
- start the docker containers: `docker-compose up -d`

### Enrolling a new Proxy

- add Proxy's entity id to ta1 configuration file, to the list of allowed entities at the /enroll endpoint
- add Proxy's entity id to ta2 configuration file, to the list of allowed entities at the /enroll endpoint
- add Proxy's entity id to tmi-sirtfi configuration file, to the list of allowed entities for issuing each of the Trust Marks
- restart the affected containers, e.g. `docker-compose restart ta1 ta2 tmi-sirtfi`
- enroll the proxy to the TA:

```bash
    curl https://ta1.g100.aarc3-pilots.vm.fedcloud.eu/enroll?sub=<proxy-entity-id>
    curl https://ta2.g100.aarc3-pilots.vm.fedcloud.eu/enroll?sub=<proxy-entity-id>
```

- restart the rp container to update its discovery information: `docker-compose restart rp`