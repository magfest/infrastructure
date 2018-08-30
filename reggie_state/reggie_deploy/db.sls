# ============================================================================
# Bump up the number of file descriptors our services are allowed to open
# ============================================================================

{%- from 'macros.jinja' import ulimit %}
{{ ulimit('reggie_deploy.db', 'postgres', 'nofile', 1048576, 1048576, watch_in=['service: postgresql']) }}


# ============================================================================
# Automated Reggie database backups
# ============================================================================

{% set db_name = salt['pillar.get']('reggie:db:name') %}
{% set backup_dir = salt['pillar.get']('reggie:db:backups:backup_dir') %}
{% set backup_schedule = salt['pillar.get']('reggie:db:backups:backup_schedule', '0 3 * * *') %}
{% set log_dir = salt['pillar.get']('reggie:db:backups:backup_log_dir') %}
{% set log_filename = salt['pillar.get']('reggie:db:backups:backup_log_filename') %}
{% set log_path = log_dir ~ '/' ~ log_filename %}
{% set preserve_local_backup_count = salt['pillar.get']('reggie:db:backups:preserve_local_backup_count', 1) %}
{% set remote_backup_dir = salt['pillar.get']('reggie:db:backups:remote_backup_dir') %}
{% set remote_backup_server = salt['pillar.get']('reggie:db:backups:remote_backup_server') %}
{% set minion_id = salt['grains.get']('id') %}


# ============================================================================
# Set up SSH keys so backup files can be shipped to the remote backup server
# ============================================================================

{% if salt['pillar.get']('reggie:db:backups:enabled') %}
/root/.ssh/known_hosts {{ remote_backup_server }}:
  file.directory:
    - name: /root/.ssh

  cmd.run:
    - name: ssh-keyscan -t rsa {{ remote_backup_server }} >> /root/.ssh/known_hosts 2>&1
    - unless: grep -q '{{ remote_backup_server }}' /root/.ssh/known_hosts


/root/.ssh/config {{ remote_backup_server }}:
  file.append:
    - name: /root/.ssh/config
    - text: |
        Host {{ remote_backup_server }}
            IdentityFile /root/.ssh/reggie_db_backups_id_rsa
{% endif %}


/root/.ssh/reggie_db_backups_id_rsa:
{% if salt['pillar.get']('reggie:db:backups:enabled') %}
  file.managed:
    - mode: 600
    - source: salt://reggie_deploy/ssh_keys/reggie_db_backups_id_rsa
{% else %}
  file.absent:
{% endif %}
    - name: /root/.ssh/reggie_db_backups_id_rsa

/root/.ssh/reggie_db_backups_id_rsa.pub:
{% if salt['pillar.get']('reggie:db:backups:enabled') %}
  file.managed:
    - mode: 644
    - source: salt://reggie_deploy/ssh_keys/reggie_db_backups_id_rsa.pub
{% else %}
  file.absent:
{% endif %}
    - name: /root/.ssh/reggie_db_backups_id_rsa.pub


# ============================================================================
# Install the reggie_db_backup script
# ============================================================================

/usr/local/bin/reggie_db_backup:
{% if salt['pillar.get']('reggie:db:backups:enabled') %}
  cmd.run:
    - name: ssh {{ remote_backup_server }} mkdir -p '{{ remote_backup_dir }}'
    - unless: test -f /usr/local/bin/reggie_db_backup

  file.managed:
    - template: jinja
    - mode: 755
    - contents: |
        #!/bin/bash

        # Reggie database backup script

        TAG="($(hostname)) ${0##*/}"
        info() { echo `date "+%F %H:%M:%S.%3N"` "[INFO] ${TAG}: ${@}"; }
        error() { >&2 echo `date "+%F %H:%M:%S.%3N"` "[ERROR] ${TAG}: ${@}"; }

        run() {
            info "${@}"
            RESULT=$( { eval "${@}"; } 2>&1 )
            ERROR=$?
            if [ $ERROR -ne 0 ]; then
                error "${@}"
            Unexpected error $ERROR:
            $RESULT"
                info 'Reggie db backup failed'
                exit $ERROR
            fi
        }

        info 'Starting reggie db backup'

        NOW=`date "+%F_%H:%M:%S.%3N"`
        SQL_FILENAME="{{ minion_id }}-${NOW}.sql"
        SQL_PATH="{{ backup_dir }}/{{ minion_id }}-${NOW}.sql"
        BACKUP_FILENAME="${SQL_FILENAME}.gz"
        BACKUP_PATH="{{ backup_dir }}/${BACKUP_FILENAME}"

        # Make sure the local backup directory exists
        if [ ! -d "{{ backup_dir }}" ]; then
            run "mkdir -p '{{ backup_dir }}'"
            run "chown postgres:postgres '{{ backup_dir }}'"
        fi

        # Dump the database into a SQL file
        run "su postgres -l -c \"pg_dump {{ db_name }} -f '${SQL_PATH}'\""

        # Compress the SQL file
        run "gzip -n '${SQL_PATH}'"

        # Make sure the backup is only user-readable
        run "chmod 600 '${BACKUP_PATH}'"

        # Copy the local backup to the remote server
        run "scp -q '${BACKUP_PATH}' '{{ remote_backup_server }}:{{ remote_backup_dir }}/'"

        info 'Finished reggie db backup'
{% else %}
  file.absent:
{% endif %}
    - name: /usr/local/bin/reggie_db_backup


/usr/local/bin/reggie_db_prune_backups:
{% if salt['pillar.get']('reggie:db:backups:enabled') %}
  pkg.installed:
    - name: fdupes

  file.managed:
    - template: jinja
    - mode: 755
    - require:
      - pkg: fdupes
    - contents: |
        #!/bin/bash

        # Deletes all but the given number of most recent Reggie database backups.
        # Defaults to keeping the {{ preserve_local_backup_count }} most recent backups.
        # Also deletes any duplicate backup files.

        set -e

        if [ "$1" != "" ]; then
          PRESERVE_COUNT=$1
        else
          PRESERVE_COUNT={{ preserve_local_backup_count }}
        fi

        # If $PRESERVE_COUNT is negative, then do nothing
        if [ $PRESERVE_COUNT -lt 0 ]; then
          exit 0
        fi

        cd {{ backup_dir }}

        # Delete duplicates before deleting old backups, no reason to keep a bunch of identical files
        fdupes -dN {{ backup_dir }}

        # Arcane black magic to delete every file while keeping the most recent
        # Safe for filenames with weird characters, spaces, or newlines
        FILE_COUNT=$(ls {{ backup_dir }}|grep \.sql\.gz$|wc -l)
        DISCARD_COUNT=$(expr $FILE_COUNT - $PRESERVE_COUNT)
        if [ $DISCARD_COUNT -gt 0 ]; then
          ls -Bt {{ backup_dir }}|grep \.sql\.gz$|tail -n $DISCARD_COUNT|tr '\n' '\0'|xargs -0 printf "%b\0"|xargs -0 rm --
        fi
{% else %}
  file.absent:
{% endif %}
    - name: /usr/local/bin/reggie_db_prune_backups


# ============================================================================
# Make sure logging directory exists
# ============================================================================

{{ log_dir }}:
  file.directory:
    - name: {{ log_dir }}


# ============================================================================
# Ensure the daily backup cron job is either present or absent, depending
# on whether or not backups are enabled.
# ============================================================================

/etc/cron.d/reggie_db_backup:
{% if salt['pillar.get']('reggie:db:backups:enabled') %}
  file.managed:
    - template: jinja
    - mode: 644
    - require:
      - file: /usr/local/bin/reggie_db_backup
      - file: /usr/local/bin/reggie_db_prune_backups
      - file: {{ log_dir }}
    - contents: |
        # Runs the Reggie database backup script

        SHELL=/bin/bash
        PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

        # m h dom mon dow  user  command
        {{ backup_schedule }}  root  /usr/local/bin/reggie_db_backup >>{{ log_path }} 2>&1 && /usr/local/bin/reggie_db_prune_backups
{% else %}
  file.absent:
{% endif %}
    - name: /etc/cron.d/reggie_db_backup


# ============================================================================
# Set up log rotation for database backup logs
# ============================================================================

/etc/logrotate.d/reggie_db_backup:
{% if salt['pillar.get']('reggie:db:backups:enabled') %}
  file.managed:
    - contents: |
        {{ log_path }} {
            weekly
            missingok
            rotate 52
            compress
            delaycompress
            notifempty
            create 640 syslog adm
            sharedscripts
            endscript
        }
{% else %}
  file.absent:
{% endif %}
    - name: /etc/logrotate.d/reggie_db_backup
