{% set public_ip = salt['grains.get']('ip4_interfaces')[salt['grains.get']('public_interface', 'eth0')][0] %}

include:
- freeipa.server


# freeipa replica private ip /etc/hosts:
#   host.only:
#     - name: {{ public_ip }}
#     - hostnames: ['ipa-02.magfest.net', 'ipa-02']


# freeipa replica master private ip /etc/hosts:
#   host.only:
#     - name: {{ salt['pillar.get']('master:address') }}
#     - hostnames: ['ipa-01.magfest.net', 'ipa-01']


# freeipa replica remove 127.0.1.1 /etc/hosts:
#   host.only:
#     - name: 127.0.1.1
#     - hostnames: []


# NOTE: In order for replication to succeed:
#       1) The host must be added to the "ipaservers" host group in FreeIPA
#       2) The replica_principal must be enabled and have the "Security Architect" role in FreeIPA
# freeipa replica install:
#   cmd.run:
#     - name: >
#         ipa-replica-install
#         --principal={{ salt['pillar.get']('freeipa:server:replica_principal') }}
#         --admin-password=$IPA_ADMIN_PASSWORD
#         --setup-ca
#         --mkhomedir
#         --no-ntp
#         --unattended
#         && touch /var/log/ipa-server-install-complete
#     - env:
#         - IPA_ADMIN_PASSWORD: {{ salt['pillar.get']('freeipa:server:replica_principal_password') }}
#     - creates: /var/log/ipa-server-install-complete
#     - require:
#       - pkg: freeipa_server_pkgs
#       - sls: freeipa.client
