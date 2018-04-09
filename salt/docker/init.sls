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

/etc/sysctl.conf:
  file.append:
    - text: net.ipv4.ip_forward=1

/usr/local/bin/docker-compose:
  cmd.run:
    - name: curl -L https://github.com/docker/compose/releases/download/1.20.1/docker-compose-{{ salt['grains.get']('kernel') }}-{{ salt['grains.get']('cpuarch') }} -o /usr/local/bin/docker-compose
    - creates: /usr/local/bin/docker-compose

docker-compose:
  file.managed:
    - name: /usr/local/bin/docker-compose
    - mode: 755
    - requires:
      - /usr/local/bin/docker-compose

pip install docker:
  pip.installed:
    - name: docker
    - require:
      - pkg: docker-ce
      - pkg: python-pip
