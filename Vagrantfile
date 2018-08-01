# -*- mode: ruby -*-
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'
VAGRANTFILE_API_VERSION = "2"
Vagrant.require_version ">= 2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "bento/ubuntu-16.04"
    config.vm.hostname = "mcp.magfest.info"

    config.vm.network :forwarded_port, guest: 80, host: 8000 # traefik http proxy
    config.vm.network :forwarded_port, guest: 443, host: 4443 # traefik https proxy

    config.vm.synced_folder ".", "/srv/infrastructure", create: true
    config.vm.synced_folder "secret", "/srv/data/secret", create: true

    # No good can come from updating plugins.
    # Plus, this makes creating Vagrant instances MUCH faster.
    if Vagrant.has_plugin?("vagrant-vbguest")
        config.vbguest.auto_update = false
    end

    # This is the most amazing module ever, it caches anything you download with apt-get!
    # To install it: vagrant plugin install vagrant-cachier
    if Vagrant.has_plugin?("vagrant-cachier")
        # Configure cached packages to be shared between instances of the same base box.
        # More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
        config.cache.scope = :box
    end

    config.vm.provider :virtualbox do |vb|
        vb.memory = 1536
        vb.cpus = 2

        # Allow symlinks to be created in /srv/infrastructure.
        # Modify "srv_infrastructure" to be different if you change the path.
        # NOTE: requires Vagrant to be run as administrator for this to work.
        vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/srv_infrastructure", "1"]
    end

    config.vm.provision :shell, inline: <<-SHELL
        set -e
        # export DEBIAN_FRONTEND=noninteractive
        # export DEBIAN_PRIORITY=critical
        # sudo -E apt-get -qy update
        # # Upgrade all packages to the latest version, very slow
        # sudo -E apt-get -qy -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" upgrade
        # sudo -E apt-get -qy autoclean
        # sudo -E apt-get -qy -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" install libssh-dev python-git swapspace

        cat >> /etc/hosts << EOF

127.0.0.1 magfest.info directory.magfest.info errbot.magfest.info ipa-01.magfest.info jenkins.magfest.info mcp.magfest.info saltmaster.magfest.info traefik.magfest.info
EOF

        mkdir -p /etc/salt
        cat >> /etc/salt/grains << EOF
env: dev
is_vagrant: True
EOF

        mkdir -p ~/.ssh
        ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts 2>&1

    SHELL

    config.vm.post_up_message = <<-MESSAGE
  All done!

  To login to your new development machine, run:
      vagrant ssh

  To bootstrap the machine, run the following command as root and follow the instructions:
      /srv/infrastructure/bootstrap-mcp.sh

    MESSAGE
end
