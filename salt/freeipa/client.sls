/etc/ssh/sshd_config PasswordAuthentication:
  file.line:
    - name: /etc/ssh/sshd_config
    - content: PasswordAuthentication no
    - match: PasswordAuthentication(?!\s+no\s*$).*$
    - mode: replace

/etc/pam.d/sshd mkhomedir:
  file.line:
    - name: /etc/pam.d/sshd
    - content: session required pam_mkhomedir.so skel=/etc/skel/ umask=0022
    - after: session\s+.+?\s+pam_selinux\.so\s+close
    - mode: ensure

freeipa-client install:
  pkg.installed:
    - name: freeipa-client

ipa-client-install:
  cmd.run:
    - name: >
        ipa-client-install
        --domain={{ salt['pillar.get']('freeipa:realm')|lower }}
        --realm={{ salt['pillar.get']('freeipa:realm')|upper }}
        --principal={{ salt['pillar.get']('freeipa:client_principal') }}
        --password={{ salt['pillar.get']('freeipa:client_password') }}
        --mkhomedir
        --no-ntp
        --force-join
        --unattended
    - creates: /etc/ipa/default.conf
    - require:
      - pkg: freeipa-client

# /etc/ssh/sshd_config PermitRootLogin:
#   file.line:
#     - name: /etc/ssh/sshd_config
#     - content: PermitRootLogin no
#     - match: PermitRootLogin(?!\s+no\s*$).*$
#     - mode: replace
#     - require:
#         - ipa-client-install
