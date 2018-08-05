# ============================================================================
# Automated Reggie database backups
# ============================================================================

{% set db_name = salt['pillar.get']('reggie:db:name') %}
{% set backup_dir = salt['pillar.get']('reggie:db:backups:backup_dir') %}
{% set backup_schedule = salt['pillar.get']('reggie:db:backups:backup_schedule', '0 3 * * *') %}
{% set preserve_local_backup_count = salt['pillar.get']('reggie:db:backups:preserve_local_backup_count', 1) %}
{% set remote_backup_dir = salt['pillar.get']('reggie:db:backups:remote_backup_dir') %}
{% set remote_backup_server = salt['pillar.get']('reggie:db:backups:remote_backup_server') %}
{% set minion_id = salt['grains.get']('id') %}


# ============================================================================
# Set up SSH keys so backup files can be shipped to the remote backup server
# ============================================================================

/root/.ssh/known_hosts {{ remote_backup_server }}:
  cmd.run:
    - name: ssh-keyscan -t rsa {{ remote_backup_server }} >> /root/.ssh/known_hosts 2>&1
    - unless: grep -q '{{ remote_backup_server }}' /root/.ssh/known_hosts


/root/.ssh/config {{ remote_backup_server }}:
  file.append:
    - name: /root/.ssh/config
    - text: |
        Host {{ remote_backup_server }}
            IdentityFile /root/.ssh/reggie_db_backups_id_rsa


/root/.ssh/reggie_db_backups_id_rsa:
  file.managed:
    - name: /root/.ssh/reggie_db_backups_id_rsa
    - mode: 600
    - source: salt://reggie_deploy/ssh_keys/reggie_db_backups_id_rsa


/root/.ssh/reggie_db_backups_id_rsa.pub:
  file.managed:
    - name: /root/.ssh/reggie_db_backups_id_rsa.pub
    - mode: 644
    - source: salt://reggie_deploy/ssh_keys/reggie_db_backups_id_rsa.pub


# ============================================================================
# Install the reggie_db_backup script
# ============================================================================

/usr/local/bin/reggie_db_backup:
  file.managed:
    - name: /usr/local/bin/reggie_db_backup
    - template: jinja
    - mode: 744
    - contents: |
        #!/bin/sh

        # Reggie database backup script

        set -e

        NOW=`date "+%F-%H:%M:%S.%3N"`
        SQL_FILENAME="{{ minion_id }}-${NOW}.sql"
        SQL_PATH="{{ backup_dir }}/{{ minion_id }}-${NOW}.sql"
        BACKUP_FILENAME="${SQL_FILENAME}.gz"
        BACKUP_PATH="{{ backup_dir }}/${BACKUP_FILENAME}"

        # Make sure the local backup directory exists
        mkdir -p {{ backup_dir }}
        chown postgres:postgres {{ backup_dir }}

        # Dump the database into a gzipped SQL file
        su postgres -l -c "pg_dump {{ db_name }} -f ${SQL_PATH}"
        gzip -n "${SQL_PATH}"

        # Make sure our backups are only user-readable
        chmod 600 {{ backup_dir }}/*

        # Make sure the remote backup directory exists
        ssh {{ remote_backup_server }} "mkdir -p {{ remote_backup_dir }}"

        # Copy the local backup to the remote server
        scp "${BACKUP_PATH}" {{ remote_backup_server }}:{{ remote_backup_dir }}/


/usr/local/bin/reggie_db_prune_backups:
  pkg.installed:
    - name: fdupes

  file.managed:
    - name: /usr/local/bin/reggie_db_prune_backups
    - template: jinja
    - mode: 744
    - require:
      - pkg: fdupes
    - contents: |
        #!/bin/sh

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

        # Delete duplicates before deleting old backups, no reason to keep a bunch of identical files
        fdupes -dN {{ backup_dir }}

        FILE_COUNT=$(ls {{ backup_dir }}|grep \.sql\.gz$|wc -l)
        DISCARD_COUNT=$(expr $FILE_COUNT - $PRESERVE_COUNT)
        if [ $DISCARD_COUNT -gt 0 ]; then
          ls -Bt {{ backup_dir }}|grep \.sql\.gz$|tail -n $DISCARD_COUNT|tr '\n' '\0'|xargs -0 printf "%b\0"|xargs -0 rm --
        fi


# ============================================================================
# Ensure the daily backup cron job is either present or absent,
# depending on whether backups are enabled or not.
# ============================================================================

/etc/cron.d/reggie_db_backup:
{% if salt['pillar.get']('reggie:db:backups:enabled') %}
  file.managed:
    - name: /etc/cron.d/reggie_db_backup
    - template: jinja
    - mode: 644
    - require:
      - file: /usr/local/bin/reggie_db_backup
      - file: /usr/local/bin/reggie_db_prune_backups
    - contents: |
        # Runs the Reggie database backup script

        SHELL=/bin/sh
        PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

        # m h dom mon dow  user  command
        {{ backup_schedule }}  root  /usr/local/bin/reggie_db_backup && /usr/local/bin/reggie_db_prune_backups
{% else %}
  file.absent:
    - name: /etc/cron.d/reggie_db_backup
{% endif %}
