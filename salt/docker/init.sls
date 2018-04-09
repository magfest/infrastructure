docker repo:
  pkgrepo.managed:
    - humanname: Docker APT Repository
    - name: deb [arch=amd64] https://download.docker.com/linux/ubuntu {{ salt['grains.get']('lsb_distrib_codename') }} stable
    - file: /etc/apt/sources.list.d/docker-ce.list
    - clean_file: True
    - require_in:
      - pkg: docker-ce
    - gpgcheck: 1
    - key_url: https://download.docker.com/linux/ubuntu/gpg

docker-ce:
  pkg.installed

/usr/local/bin/docker-compose:
  cmd.run:
    - name: curl -L https://github.com/docker/compose/releases/download/1.20.1/docker-compose-{{ salt['grains.get']('kernel') }}-{{ salt['grains.get']('cpuarch') }} -o /usr/local/bin/docker-compose
    - creates: /usr/local/bin/docker-compose

docker-compose:
  file.managed:
    - mode: 755

pip install docker:
  pip.installed:
    - name: docker
    - require:
      - pkg: docker-ce
      - pkg: python-pip
