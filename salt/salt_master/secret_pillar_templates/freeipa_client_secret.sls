{%- set admin_password = salt["random.get_str"](14) -%}

freeipa_client:
  realm: 'magfest.org'
  admin_password: {{ admin_password }}
