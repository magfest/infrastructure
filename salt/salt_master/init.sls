# ============================================================================
# Salt master prerequisites
# ============================================================================

# Salt needs libssh-dev and python-git to clone github repositories
libssh-dev install:
  pkg.installed:
    - name: libssh-dev

python-git install:
  pkg.installed:
    - name: python-git


# ============================================================================
# Secret infrastructure configuration
# ============================================================================

{%- set secret_infrastructure = salt['pillar.get']('data:path') ~ '/secret/infrastructure' %}

# Create directory if it doesn't exist
{{ secret_infrastructure }}/:
  file.directory:
    - mode: 700
    - makedirs: True

# Initialize a local git repository. This is mostly to help admins track
# updates to their secret data.
{{ secret_infrastructure }}/ git init:
  git.present:
    - name: {{ secret_infrastructure }}/
    - bare: False

# No need to track changes to *.example or README.md, because those files are
# under configuration management.
{{ secret_infrastructure }}/ git ignore:
  file.managed:
    - name: {{ secret_infrastructure }}/.gitignore
    - contents: |
        *.example
        README.md
    - require:
      - git: {{ secret_infrastructure }}/

# Put README.md under configuration management, so local changes are reverted
{{ secret_infrastructure }}/README.md:
  file.managed:
    - source: salt://salt_master/secret_infrastructure/README.md
    - mode: 600
    - template: jinja
    - require:
      - git: {{ secret_infrastructure }}/

# Copy secret_infrastructure salt files
# NOTE: These ARE NOT treated as Jinja templates
{{ secret_infrastructure }}/salt/ files:
  file.recurse:
    - name: {{ secret_infrastructure }}/salt/
    - source: salt://salt_master/secret_infrastructure/salt
    - dir_mode: 700
    - file_mode: 600
    - makedirs: True
    - require:
      - git: {{ secret_infrastructure }}/

# Copy secret_infrastructure pillar files
# NOTE: These ARE treated as Jinja templates
{{ secret_infrastructure }}/pillar/ files:
  file.recurse:
    - name: {{ secret_infrastructure }}/pillar/
    - source: salt://salt_master/secret_infrastructure/pillar
    - dir_mode: 700
    - file_mode: 600
    - makedirs: True
    - replace: False
    - template: jinja
    - require:
      - git: {{ secret_infrastructure }}/

{% for filename in salt['file.find'](secret_infrastructure ~ '/pillar/*.sls', print='name') -%}
{{ secret_infrastructure }}/pillar/{{ filename }} example:
  file.blockreplace:
    - name: {{ secret_infrastructure }}/pillar/{{ filename }}
    - marker_start: '# == Start Example ======'
    - content: salt://salt_master/secret_infrastructure/pillar
    - marker_end: '# == End Example ========'
    - prepend_if_not_found: True
{% endfor %}

# ============================================================================
# SSH client configuration
# ============================================================================

/root/.ssh/ public keys:
  file.recurse:
    - name: /root/.ssh/
    - makedirs: True
    - include_pat: '*.pub'
    - file_mode: 644
    - source: salt://salt_master/ssh_keys

/root/.ssh/ private keys:
  file.recurse:
    - name: /root/.ssh/
    - exclude_pat: 'E@\.*\.pub|README\.md'
    - file_mode: 600
    - source: salt://salt_master/ssh_keys

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


# ============================================================================
# Salt master configuration
# ============================================================================

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
