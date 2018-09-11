base:
  '*':
    - defaults

  'not bootstrap':
    - freeipa_client
    - freeipa_client_secret
    - ignore_missing: True

  'G@roles:ipa':
    - freeipa_server
    - freeipa_server_secret
    - ignore_missing: True

  'G@roles:ipa-replica':
    - freeipa_replica

  'G@roles:ipa-master':
    - freeipa_master

  'G@roles:saltmaster or bootstrap':
    - freeipa_server
    - freeipa_master
    - saltmaster

  'G@roles:saltmaster':
    - digitalocean_secret
    - freeipa_server_secret
    - magbot_secret
    - saltmaster_secret
    - slack_irc_secret
    - ignore_missing: True

  'archive.uber.magfest.org':
    - archive_uber_magfest_org

  'backups.uber.magfest.org':
    - backups_uber_magfest_org

  'docker.uber.magfest.org':
    - docker_uber_magfest_org

  'G@is_vagrant:True':
    - vagrant
