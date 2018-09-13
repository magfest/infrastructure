# MAGFest IT Infrastructure

What do you want to do today?


## Update Reggie Config

Looking to update some values in the Reggie config? Try looking in the
[reggie_config](reggie_config) directory!


## Provision a Reggie Cloud Server for a New Event

Do you want to provision a Reggie server for a new event? Take a look at the
[salt cloud README](magfest_state/salt/cloud/README.md)!


## Set Up a Reggie Development Environment

Do you want to set up a Reggie development environment? Follow the
instructions in the [reggie-formula repository](https://github.com/magfest/reggie-formula).


## SSH Access to MCP

SSH access to mcp.magfest.net is controlled by our FreeIPA server at
https://directory.magfest.net. As of now, only users in the `admins` group
are granted access to mcp.magfest.net. SSH authentication requires an SSH key,
so you'll need to upload your SSH public key to https://directory.magfest.net.

*NOTE*: The FreeIPA user interface is a little wonky when it comes to
uploading SSH keys. After copy/pasting your key into the text field and
clicking "Set", it _looks_ like the key has been uploaded, but you must
still click the "Save" button at the top of the screen. *YOUR KEY WILL
NOT BE UPLOADED UNTIL YOU CLICK "SAVE" AT THE TOP OF THE SCREEN*.


## Run Salt Commands On MCP

Looking for info on how to run salt commands on MCP? Try the
[Salt Master README](magfest_state/salt/master/README.md)!
