# SSH Keys Used By Salt Master

Place any SSH keys the Salt Master should use in this directory. These will
end up in `/root/.ssh`. At a minimum, you'll probably want `id_rsa` and
`id_rsa.pub` which are used by the `legacy_deploy` to configure servers using
fabric and puppet.
