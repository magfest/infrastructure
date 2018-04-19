{%- set admin_password = salt['pillar.get']('freeipa:admin_password', salt['random.get_str'](14)) -%}

freeipa:
  ds_password: '{{ salt["random.get_str"](24) }}'
  admin_password: '{{ admin_password }}'
