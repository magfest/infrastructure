# ============================================================================
# Bump up the number of file descriptors our services are allowed to open
# ============================================================================

{%- from 'macros.jinja' import ulimit %}
{{ ulimit('reggie_deploy.loadbalancer', 'haproxy', 'nofile', 1048576, 1048576, watch_in=['service: haproxy']) }}
