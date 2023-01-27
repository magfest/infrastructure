# Uber Configuration

This repo stores the public configuration values for all MAGFest Uber servers.

Each server gets deployed with an ordered list of paths within this repository and
will merge them in order to arrive at a final configuration.

## Example

For example, the MAGFest Super 2024 production server gets configured with these paths:

* environments/prod
* events/super/2024/prod

With this list it will evaluate the following paths, in order:

* environments/*.yaml
* environments/prod/*.yaml
* events/*.yaml
* events/super/*.yaml
* events/super/2024/*.yaml
* events/super/2024/prod/*.yaml

The later files take precedence over the earlier files.

Each glob matches files in alphabetical order, however it is discouraged to 
put overlapping values in multiple files in the same directory.