freeipa:
  ds_password: '{{ salt["random.get_str"](24) }}'
  admin_password: '{{ salt["random.get_str"](14) }}'

traefik:
  users:
    admin: '{{ salt["random.get_str"](14) }}'
