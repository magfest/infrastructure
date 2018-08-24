freeipa:
  client_principal: 'svc_deploy'
  client_password: '{{ salt["random.get_str"](14) }}'
