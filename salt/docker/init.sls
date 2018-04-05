docker repo:
  pkgrepo.managed:
    - humanname: Docker APT Repository
    - name: deb [arch=amd64] https://download.docker.com/linux/ubuntu {{ salt['grains.get']('lsb_distrib_codename') }} stable
    - dist: stable
    - file: /etc/apt/sources.list.d/docker-ce.list
    - require_in:
      - pkg: docker-ce
    - gpgcheck: 1
    - key_url: https://download.docker.com/linux/ubuntu/gpg

docker-ce:
  pkg.installed

pip install docker:
  pip.installed:
    - name: docker
    - require:
      - pkg: docker-ce
      - pkg: python-pip
