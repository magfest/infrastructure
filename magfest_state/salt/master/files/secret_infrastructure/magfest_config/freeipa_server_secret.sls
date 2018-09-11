freeipa:
  server:
    dm_password: '{{ salt["random.get_str"](24) }}'
    admin_password: '{{ salt["random.get_str"](14) }}'
    replica_principal: 'svc_replica'
    replica_principal_password: '{{ salt["random.get_str"](24) }}'
