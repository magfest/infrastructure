{%- set secret_pillar = salt['pillar.get']('data:path') ~ '/secret/pillar' -%}

libssh-dev install:
  pkg.installed:
    - name: libssh-dev

python-git install:
  pkg.installed:
    - name: python-git

git config autocrlf:
  git.config_set:
    - name: autocrlf
    - value: 'false'
    - global: True

{{ secret_pillar }}/:
  file.directory:
    - mode: 700
    - makedirs: True

{{ secret_pillar }}/ git init:
  git.present:
    - name: {{ secret_pillar }}/
    - bare: False

{{ secret_pillar }}/ git ignore:
  file.managed:
    - name: {{ secret_pillar }}/.gitignore
    - contents: |
        *.example
        README.md
    - require:
      - git: {{ secret_pillar }}/

{{ secret_pillar }}/*.example:
  file.recurse:
    - name: {{ secret_pillar }}/
    - source: salt://salt_master/secret_pillar_templates
    - dir_mode: 700
    - file_mode: 600
    - makedirs: True
    - replace: False
    - template: jinja
    - require:
      - git: {{ secret_pillar }}/

{{ secret_pillar }}/ copy example templates:
  cmd.run:
    - name: for f in {{ secret_pillar }}/*.example; do cp --no-clobber -- "$f" "${f%.example}"; done
    - onchanges:
      - {{ secret_pillar }}/*.example

{{ secret_pillar }}/README.md:
  file.managed:
    - source: salt://salt_master/secret_pillar_templates/README.md
    - mode: 600
    - template: jinja
    - require:
      - git: {{ secret_pillar }}/

/etc/salt/master:
  file.managed:
    - source: salt://salt_master/salt_master.conf
    - mode: 644
    - makedirs: True
    - template: jinja

salt_master:
  service.running:
    - name: salt-master
    - watch:
      - file: /etc/salt/master
    - require_in:
      - sls: salt_minion

/root/.ssh/:
  file.directory:
    - mode: 644
    - makedirs: True

/root/.ssh/authorized_keys:
  file.append:
    - text: |
        ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2eSXsBB78a1s0/Dr6CZ4fbtnuQAuY8/p+efHnP16/IHYKsdEwAz+W+NppnLVkeV8pm9YSMpbiiD6fjncctmi73PzUM9JHCAyi5ImRsKi9KmNNpGjNlwZACUIIFTVnJmOGXUEHU5rnNTUJR41UuJtY8PrxpQxrN3bWjcrgIFNRRwBk0RHl6m5jfTP7RZ3ie8ipfrWYdsSitwhr+VD1+5uTfPMzpnpe4jvBKWAWoP72Dn0lfD+/ht9kg0YziWLLgJrmTWKPqBhLNXkFW5sXUwrFYIoJkCADZL4SAIIxJbXrfaSzRRVSy5vFdwvcFhR0/9afF13puXmrxorNAvjIA3Dv saltmaster@magfest.org
        ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCcOrXauQnNPMqsdw1pDqZlVnx0B80mu/ZJK9TptZVM6/oSgWArO9o3kuTQJpE/GfEwY+z3mQBnrR9IYVhNXS2ouaJy8TvvGredvBNOIk3mX083jIHYeRWBiSBctCmanR3Zuz7XEarCO2SdL5nk9lF0viX83fRHjHNsmN7zIi8tYdPK9ITfnLzGfKXn9TK+IFVMNZ002zQeTFGT63E2JZCh+BotMeEzPOcm5W12F3r1PTV579jyPemtc5iLBJX2LD7RbuCmHi7UL948Crqtq1Y1RiGuGFOGx6+pp6D/gSgGDIsEdbEaejlN14rqcWaDrU2D5BNFHbx5UiCLXT4sx8Nv robruana@magfest.org
        ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJKBZzNEJxzeLOytMa6lhz2DiRjlHxXvG/qfFIa2SZXY/+IPb7MYEbDhCVBCmSBRgcEx0XqRLs865om/R0t0zUrH5IDwojveQ92I3DzKjkAtrwSbAFpFqNp4vC0+N0ZS0t+lKpMXSlczbwKvZ9LdvHKwDVVjhJDqhvwuiyXCnuTa2ad4ZoAAlBVyn7FCKAXlxfyX0+Kk+J7YLhEm2UGSXmkX61g28I0BczXiPE9veUZtO6POFZ8puX0Av3Pv2rZEPBdpCJYPtUsOpOAXJgYudP9V7ztlcU2nVbPwiBN+ZK9yfYzQa8OWjIUSgUudM7eFRVFu1s0Kyg8xC0VRFYKY6l dom@magfest.org

/root/.ssh/known_hosts:
  file.append:
    - text: |
        # github.com:22 SSH-2.0-libssh_0.7.0
        |1|mMeDA6mliM8YrKh6n490Mlr489Y=|fSwqDfWnJHEIBEEJ7xAPSvYKMlc= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==

{% for ssh_key_name, ssh_key in salt['pillar.get']('master:ssh_keys').items() %}
/root/.ssh/{{ ssh_key_name }}.pub:
  file.managed:
    - mode: 644
    - contents: {{ ssh_key['public'] }}

/root/.ssh/{{ ssh_key_name }}.pem:
  file.managed:
    - mode: 600
    - contents: |
        {{ ssh_key['private']|indent(8) }}
{% endfor %}
