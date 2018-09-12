{% include header.html %}

# Technologies We Use

See also [Services We Use](services.html)

<h1><img src="assets/images/python.png" alt="Python" class="inline"/></h1>

It would be fair to say MAGFest is a [Python](https://python.org) shop. We're
always interested in new technologies and new languages, but the bulk of the
software we produce is written in Python. Notably,
[Reggie](https://github.com/magfest/reggie-formula) — our registration
software — and [MAGBot](https://github.com/magfest/magbot) — our ChatOps
bot — are both written in Python.


<h1><img src="assets/images/celery-rabbitmq.png" alt="Celery" class="inline"/></h1>

All of Reggie's background tasks run on [Celery](http://www.celeryproject.org),
communicating via [Rabbit MQ](https://www.rabbitmq.com).


<h1><img src="assets/images/postgresql.png" alt="PostgreSQL" class="inline"/></h1>

[PostgreSQL](https://www.postgresql.org) is our database of choice for Reggie.


<h1><img src="assets/images/nginx.png" alt="NGINX" class="inline"/></h1>

Our Python web services are all served by [NGINX](https://www.nginx.com).


<h1><img src="assets/images/haproxy.png" alt="HAProxy" class="inline"/></h1>

Reggie uses [HAProxy](http://www.haproxy.org) community edition as the
front-end loadbalancer for web traffic.


<h1><img src="assets/images/glusterfs.png" alt="GlusterFS" class="inline"/></h1>

Reggie uses [GlusterFS](https://docs.gluster.org) for its distributed
network filesystem.


<h1><img src="assets/images/redis.png" alt="Redis" class="inline"/></h1>

Reggie uses [Redis](https://redis.io) to store web sessions.


<h1><img src="assets/images/saltstack.png" alt="SaltStack" class="inline"/></h1>

We use [SaltStack](https://github.com/saltstack/salt) for configuration
management of all our servers.


<h1><img src="assets/images/ubuntu.png" alt="Ubuntu" class="inline"/></h1>

It would also be fair to say that MAGFest is an Ubuntu shop, in that almost
all of our servers run some version of Ubuntu. We've embraced systemd, which
we use to run all of our custom Python services.
