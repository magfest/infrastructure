# Master Control Program Server
### [mcp.magfest.net](https://mcp.magfest.net)

MCP is the central piece of MAGFest's IT infrastructure. MCP provisions and
manages the configuration of all of our other servers.

<img src="assets/images/mcp.png" alt="MCP Network Diagram" class="inline"/>

## Bootstrapping the MCP server

Creating an MCP server should only need to be done rarely; ideally just once.

### Step 1 – Create Server

Create a new droplet on [https://digitalocean.com](https://digitalocean.com)
  * Ubuntu 16.04.4 x64
  * Add a block storage volume (this will need to be mounted on `/srv/data`)
  * Select "Private Networking" and "Monitoring"
  * Add the following SSH Keys: "Saltmaster", "Rob Ruana", and "DomMCP"

### Step 2 – Run Bootstrap Script

As root/sudo run the following command and follow the instructions it prints when finished
(replace SALT_ENV as appropriate):
```
curl -L https://github.com/magfest/infrastructure/raw/master/bootstrap-mcp.sh | SALT_ENV=staging sh
```
