freeipa_server_pkgs:
  pkg.installed:
    - names:
      - rng-tools  # rng-tools help generate entropy for the freeipa server install.
      - freeipa-server
