docker-engine:
  pkg.installed

pip install docker:
  pip.installed:
    - name: docker
    - require:
      - pkg: docker-engine
      - pkg: python-pip
