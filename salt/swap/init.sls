coreutils:
  pkg.installed

/swapfile:
  cmd.run:
    - name: |
        [ -f /swapfile ] || dd if=/dev/zero of=/swapfile bs=1M count={{ grains['mem_total'] * 2 }}
        chmod 0600 /swapfile
        mkswap /swapfile
        swapon -a
    - unless:
      - file /swapfile 2>&1 | grep -q "Linux/i386 swap"
  mount.swap:
    - persist: true
