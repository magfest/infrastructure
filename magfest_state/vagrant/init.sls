vagrant /etc/hosts:
  host.present:
    - ip: 127.0.0.1
    - names:
      - {{ salt['pillar.get']('freeipa:hostname') }}
      - {{ salt['pillar.get']('freeipa:ui_domainname') }}
      - {{ salt['pillar.get']('traefik:ui_domainname') }}
      {% for subdomain in salt['pillar.get']('traefik:subdomains') %}
      - {{ subdomain }}.{{ salt['pillar.get']('traefik:domain') }}
      {% endfor %}
