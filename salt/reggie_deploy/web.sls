# ============================================================================
# Delete nginx cache if there are code updates
# ============================================================================
delete nginx cache:
  cmd.run:
    - name: 'find /var/cache/nginx/**/* -type f | xargs rm'
    - onlyif: 'find /var/cache/nginx/**/* -type f 2> /dev/null | grep -q /var/cache/nginx/'
    - onchanges:
      - sls: reggie.install
