{%- set name = data.get("name", data.get("data", {}).get("name")) -%}

{%- if name -%}
freeipa client unenroll:
  local.cmd.run:
    - tgt: '{{ name }}'
    - args:
      - cmd: 'ipa-join --unenroll --hostname={{ name }}'
{% endif %}
