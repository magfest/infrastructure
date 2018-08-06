# ============================================================================
# Delete nginx cache if there are code updates
# ============================================================================

delete nginx cache:
  cmd.run:
    - name: 'find /var/cache/nginx/**/* -type f | xargs rm'
    - onlyif: 'find /var/cache/nginx/**/* -type f 2> /dev/null | grep -q /var/cache/nginx/'
    - onchanges:
      - sls: reggie.install


# ============================================================================
# Make sure uploaded files directories exist
# ============================================================================

{% set config_dirs = [
    'data_dir',
    'mounted_data_dir',
    'uploaded_files_dir',
    'guests_bio_pics_dir',
    'guests_inventory_dir',
    'guests_stage_plots_dir',
    'guests_w9_forms_dir',
    'mits_picture_dir',
    'mivs_game_image_dir',
] %}

{% for config_dir in config_dirs %}
{% set directory = salt['pillar.get']('reggie:plugins:ubersystem:config:' ~ config_dir) %}
{% if directory %}
reggie create {{ directory }}:
  file.directory:
    - name: {{ directory }}
    - makedirs: True
    - user: {{ salt['pillar.get']('reggie:user') }}
    - group: {{ salt['pillar.get']('reggie:group') }}
    - recurse:
      - user
      - group
    - require:
      - sls: glusterfs.client
      - sls: reggie.web
{% endif %}
{% endfor %}
