# Reggie Config using Pillar Stack

Please see the [pillar stack documentation](https://docs.saltstack.com/en/latest/ref/pillar/all/salt.pillar.stack.html)
for full details on how pillar stack works. The primary motivation for using
pillar stack is so each file has full access to all previously loaded pillar
stack data. Regular SaltStack pillar files can't easily access other pillar
data, which can make it difficult to share settings like database passwords
across files.

Files are loaded in the following order, with earlier files taking precedence:

```
event_year_environment/init.yaml
event_year_environment/role.yaml
event_year/init.yaml
event_year/role.yaml
event_environment/init.yaml
event_environment/role.yaml
event/init.yaml
event/role.yaml
environment/init.yaml
environment/role.yaml
init.yaml
role.yaml
```

Where:
* `event` is the name of the event (super, stock, labs, west)
* `year` is the year of the event (2018, 2019, 2020)
* `role` is the role played by the server (db, web, scheduler, worker)

If a server has more than one role, the role files will be loaded sequentially.

For example, the database server for Super 2019 would load files in this order:

```
super_2019_staging/init.yaml
super_2019_staging/db.yaml
super_2019/init.yaml
super_2019/db.yaml
super_staging/init.yaml
super_staging/db.yaml
super/init.yaml
super/db.yaml
staging/init.yaml
staging/db.yaml
init.yaml
db.yaml
```

Data from any of the previously loaded files can be accessed using the Jinja
`stack` variable, like this: `{{ stack['reggie']['db']['username'] }}`.

The `init.yaml` file in each directory should open with the following line:
```
__: merge-first
```

Any _other_ files (like `db.yaml`) should **not** include the `merge-first`
directive. This ensures the settings are merged in the correct order, and
are available in any subsequently loaded file.
