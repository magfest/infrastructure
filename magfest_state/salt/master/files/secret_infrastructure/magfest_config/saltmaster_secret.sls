traefik:
  users:
    admin: '{{ salt["random.get_str"](14) }}'
