traefik:
  users:
    admin: '{{ salt["random.get_str"](14) }}'


tinc:
  hosts:
    reggienet:
      private_key: ''
