# ============================================================================
# Install glusterfs from PPA.
# The default Ubuntu 18.04 package currently hangs on install.
# ============================================================================
glusterfs-server install:
  pkgrepo.managed:
    - name: gluster/glusterfs-3.13
    - ppa: gluster/glusterfs-3.13

  pkg.installed:
    - name: glusterfs-server
    - refresh: True
    - require:
      - pkgrepo: gluster/glusterfs-3.13
    - require_in:
      - sls: glusterfs.server
      - sls: glusterfs.client
