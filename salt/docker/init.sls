pip install docker:
  pip.installed:
    - name: docker
    - require:
      - pkg: python-pip
