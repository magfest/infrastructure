{%- set freeipa_admin_password = '{{ salt['random.get_str'](14) }}' -%}

freeipa:
  ds_password: '{{ salt["random.get_str"](24) }}'
  admin_password: '{{ freeipa_admin_password }}'

traefik:
  users:
    admin: '{{ salt["random.get_str"](14) }}'
