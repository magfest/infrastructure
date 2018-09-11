{% set public_ip = salt['grains.get']('ip4_interfaces')[salt['grains.get']('public_interface', 'eth0')][0] %}

include:
- freeipa.server


# NOTE: In order for replication to succeed:
#       1) The host must be added to the "ipaservers" host group in FreeIPA
#       2) The replica_principal must be enabled and have the "Security Architect" role in FreeIPA
freeipa server install:
  cmd.run:
    - name: >
        ipa-server-install
        --domain={{ salt['pillar.get']('freeipa:server:domain', salt['pillar.get']('freeipa:server:realm'))|lower }}
        --realm={{ salt['pillar.get']('freeipa:server:realm')|upper }}
        --ds-password={{ salt['pillar.get']('freeipa:server:dm_password') }}
        --admin-password={{ salt['pillar.get']('freeipa:server:admin_password') }}
        --mkhomedir
        --no-ntp
        --unattended
        && touch /var/log/ipa-server-install-complete
    - creates: /var/log/ipa-server-install-complete
    - require:
      - pkg: freeipa_server_pkgs
      - sls: freeipa.client
