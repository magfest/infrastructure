freeipa_server:
  ds_password: '{{ salt["random.get_str"](24) }}'
