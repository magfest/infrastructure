{% set public_ip = salt['grains.get']('ip4_interfaces')[salt['grains.get']('public_interface', 'eth0')][0] %}

tinc install:
  pkg.installed:
    - name: tinc

tinc reggienet tinc.conf:
  file.managed:
    - name: /etc/tinc/reggienet/tinc.conf
    - makedirs: True
    - template: jinja
    - contents: |
        Name = mcp
        AddressFamily = ipv4
        Interface = tun0

tinc reggienet tinc-up:
  file.managed:
    - name: /etc/tinc/reggienet/tinc-up
    - makedirs: True
    - template: jinja
    - contents: |
        #!/bin/sh
        ifconfig $INTERFACE 192.168.0.2 netmask 255.255.255.0

tinc reggienet tinc-down:
  file.managed:
    - name: /etc/tinc/reggienet/tinc-down
    - makedirs: True
    - mode: 755
    - template: jinja
    - contents: |
        #!/bin/sh
        ifconfig $INTERFACE down

tinc reggienet hosts mcp:
  file.managed:
    - name: /etc/tinc/reggienet/hosts/mcp
    - makedirs: True
    - mode: 755
    - template: jinja
    - contents: |
        Address = {{ public_ip }}
        Subnet = 192.168.0.2/32

        -----BEGIN RSA PUBLIC KEY-----
        MIICCgKCAgEA1HvnokAj5jziBxrj8n1qh9CdfWq7WVT1/TFKkFRigvUYAJLaKpw0
        KFpPigalSLBaAJz6ExIttO5BUPD7s0mCuD9wBr4K9SGiQHKtNL1z8SNFnxe9GJVR
        gfYL7wm9+QlsAdtiY2rdsRl4xUTboV3E6vjb0pBl8+GtO4Sjgjuy98h7DGe3yT0o
        S7Hp3xvciKF+G5alFt7bGp7BrhmhgTt7Pj52Cu8wLni2MXE0Gjeowv7epJ7Rt/Oy
        bkEqXREO9AAoH/3kJ+73y4n92o9bsU06/H6LDm6uQ+Otm8bWF7o3BvDgm83hdOoM
        ygH3/vpAVWJ2p2Nh+qad91PmS0U91AAElHSzUT2Dm6a5hQxmkDvKUqeUgLhzN7Ha
        vZ5RT1bWnVdwIuZW4qiepzzmcrhx2dPByalL7kjvHUqMk2x50jIIYI//7ArkxBdR
        lidNkk9EXlq+4ODKYtx7ZC+/aG/UfmMADWjB7iMDC8anT2eI2pljWr4OsKnaSn4l
        eCbY+r7kIUDWDfsyiNtb+p5OJxg5DJtSzcYAcT+AAT4cKWdafuDV39jfEB/Ql+4/
        3/CTx/lxSZ7lJCjkI98MXmMBVSz0t0w5a7KzNzQB9QY4csrl57u4oFnYMrlQ+BeM
        2VMkiVtuRSELCeGAhnMcYrLrrxAR83ScfUHcmABCd96HIaXV5TIccEcCAwEAAQ==
        -----END RSA PUBLIC KEY-----

tinc reggienet hosts private key:
  file.managed:
    - name: /etc/tinc/reggienet/rsa_key.priv
    - makedirs: True
    - mode: 600
    - contents_pillar: 'tinc:hosts:reggienet:private_key'
