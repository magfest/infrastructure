# Jenkins
### [jenkins.magfest.net](https://jenkins.magfest.net)

<div class="bs-callout bs-callout-info bg-white">
  <h4>Jenkins Authentication</h4>
  Jenkins is configured to authenticate against our <a href="freeipa.html">FreeIPA</a>
  server. Jenkins users must belong to either the <code>jenkins-users</code> group, or
  the <code>developers</code> group. Jenkins administrators must belong to the
  <code>jenkins-admins</code> group or the <code>admins</code> group.
</div>

# Configure Jenkins

Manage Jenkins > Configure Global Security > Advanced Server Configuration

```
Server: ldaps://ipa-01.magfest.org
root DN: dc=magfest,dc=org
User search base: cn=users,cn=accounts
User search filter: uid={0}
Group search base:
Group search filter:
Group membership: Search for LDAP groups containing user
    Group membership filter: (| (member={0}) (uniqueMember={0}) (memberUid={1}))
Manager DN: uid=svc_jenkins,cn=users,cn=accounts,dc=magfest,dc=org
Manager Password: secret
```
