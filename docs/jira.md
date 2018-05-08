# Jira

Our [Jira issue tracking server](https://jira.magfest.net) is a core piece of
MAGFest's infrastructure. The server is hosted on one of our Digital Ocean
droplets (hostname jira.magfest.net). Our daily office tasks, as well as all
of our other projects – including our software development projects – are
tracked and managed in Jira.

## GitHub Integration

Our Jira server is integrated with our
[MAGFest account](https://github.com/magfest) on GitHub. Every repository owned
by the MAGFest account will automatically have webhooks installed that POST
git events back to our Jira Software server.

See the [DVCS accounts](https://jira.magfest.net/secure/admin/ConfigureDvcsOrganizations!default.jspa)
page for details about the Jira settings.

See the [OAuth Apps](https://github.com/organizations/magfest/settings/applications)
page for details about the Jira app registered with our GitHub
account. See the [infrastructure webhooks](https://github.com/magfest/infrastructure/settings/hooks)
for examples of the webhooks installed by the Jira app.

## Referencing Jira Issues In Git Commits

Git commit messages should use the following format to reference related issues
in Jira:
```
ISSUE-KEY #WORKFLOW Short description of change.
```

For example:
```
git commit -m "OFFICE-4039 #in-progress Adds Jira page to infrastructure docs."
```

A complete description of Jira smart commits can be
[found here](https://confluence.atlassian.com/bitbucket/processing-jira-software-issues-with-smart-commit-messages-298979931.html).


**NOTE**: While `ISSUE-KEY` links will always be recognized by Jira, smart
commit `#WORKFLOWS` will only work if the committer's email address matches the
email address of a Jira Software user with the relevant permission.