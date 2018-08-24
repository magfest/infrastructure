# ============================================================================
# Installs Docker and the libraries required by Docker salt states
# ============================================================================

include:
  - pip

# Docker has it's own APT Repository
docker install:
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

  pkg.installed:
    - name: docker-ce

  pip.installed:
    # Docker salt states, e.g docker_container, require the python docker package
    - name: docker
    - reload_modules: True
    - require:
      - pkg: docker-ce
      - pkg: python-pip

# Docker networking requires IP forwarding to be enabled
/etc/sysctl.conf net.ipv4.ip_forward = 1:
  file.append:
    - name: /etc/sysctl.conf
    - text: net.ipv4.ip_forward = 1

# # Disable ipv6 in sysctl.conf
# /etc/sysctl.conf net.ipv6.conf.*.disable_ipv6 = 1:
#   file.append:
#     - name: /etc/sysctl.conf
#     - text:
#       - net.ipv6.conf.all.disable_ipv6 = 1
#       - net.ipv6.conf.default.disable_ipv6 = 1
#       - net.ipv6.conf.lo.disable_ipv6 = 1
#       - net.ipv6.conf.eth0.disable_ipv6 = 1

# Make sysctl changes take effect
restart sysctl:
  cmd.run:
    - name: sysctl --system
    - onchanges:
      - file: /etc/sysctl.conf

# # Disable ipv6 in the kernel
# /etc/default/grub ipv6.disable=1:
#   file.append:
#     - name: /etc/default/grub
#     - text: GRUB_CMDLINE_LINUX_DEFAULT="ipv6.disable=1 quiet splash"

# # Make grub changes take effect
# update grub:
#   cmd.run:
#     - name: update-grub
#     - onchanges:
#       - file: /etc/default/grub
