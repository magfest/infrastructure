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

docker-ce install:
  pkg.installed:
    - name: docker-ce

/etc/sysctl.conf ip_forward:
  file.append:
    - name: /etc/sysctl.conf
    - text: net.ipv4.ip_forward=1

pip install docker:
  pip.installed:
    - name: docker
    - require:
      - pkg: docker-ce
      - pkg: python-pip
