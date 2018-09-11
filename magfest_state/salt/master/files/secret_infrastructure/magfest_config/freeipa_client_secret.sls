freeipa:
  client:
    principal: 'svc_deploy'
    principal_password: '{{ salt["random.get_str"](14) }}'
