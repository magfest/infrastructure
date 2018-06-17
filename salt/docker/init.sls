# ============================================================================
# Installs Docker and the libraries required by Docker salt states
# ============================================================================

include:
  - pip

# Docker has it's own APT Repository
docker repo:
  pkgrepo.managed:
    - humanname: Docker APT Repository
    - name: >
        deb [arch=amd64] https://download.docker.com/linux/ubuntu
        {{ salt['grains.get']('lsb_distrib_codename') }} stable
    - file: /etc/apt/sources.list.d/docker-ce.list
    - clean_file: True
    - gpgcheck: 1
    - key_url: https://download.docker.com/linux/ubuntu/gpg
    - require_in:
      - pkg: docker-ce

docker-ce install:
  pkg.installed:
    - name: docker-ce
    - reload_modules: True

# Docker networking requires IP forwarding to be enabled
/etc/sysctl.conf ip_forward:
  file.append:
    - name: /etc/sysctl.conf
    - text: net.ipv4.ip_forward=1

# Docker salt states, e.g docker_container, require the python docker package
pip install docker:
  pip.installed:
    - name: docker
    - reload_modules: True
    - require:
      - pkg: docker-ce
      - pkg: python-pip
