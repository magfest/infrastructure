{%- set name = data.get('name', data.get('data', {}).get('name', '*')) -%}

salt_cloud_created_orchestrate:
  runner.state.orchestrate:
    - args:
      - mods: orchestration.salt_cloud_created
      - pillar:
          id: '{{ name }}'
