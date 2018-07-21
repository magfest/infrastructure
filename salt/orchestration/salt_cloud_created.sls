saltutil.sync_all:
  salt.function:
    - tgt: '{{ salt["pillar.get"]("id") }}'
    - reload_modules: True

saltutil.refresh_pillar:
  salt.function:
    - tgt: '{{ salt["pillar.get"]("id") }}'

mine.update:
  salt.function:
    - tgt: '{{ salt["pillar.get"]("id") }}'

highstate_run:
  salt.state:
    - tgt: '{{ salt["pillar.get"]("id") }}'
    - tgt_type: compound
    - highstate: True
