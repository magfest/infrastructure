{{ salt['pillar.get']('data_path') }}/letsencrypt/etc/letsencrypt/live/:
  file.directory:
    - mode: 700
    - makedirs: True

{{ salt['pillar.get']('data_path') }}/letsencrypt/var/lib/letsencrypt/:
  file.directory:
    - mode: 700
    - makedirs: True
