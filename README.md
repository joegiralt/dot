# Nix(OS) Configurations

This repository contains configurations for various programs & Nix(OS).
This Nix(OS) section of this repository is located in the `nixos` directory. 

## Pre Requisites
### Install Home Manager CLI
```bash
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
```

## Using Docker Compose to Check Configs

```bash
docker compose run --remove-orphans check
```

## File Structure
### nixos/hosts

- The `hosts` contains the `configuration.nix` files for each of my computers that runs NixOS. 
- Each host is assigned a separate folder. 
- The configuration that `flake.nix` uses is decided by the hostname of the system.
- The creation of users is managed by the `configuration.nix` but all the user related configuration is handled by `home-manager`. The common link between the created user and configured user is just the username. This means that users with the same name on all systems will be configured the same way if `home-manager` is used configure the user.

### users
- The `users` directory is the `home-manager` section of the configuration.
- Each username has a `username.nix` file that contains user level `home-manager` managed configurations.
- The `users/shared` directory contains modules that are shared across multiple users.

### secrets

- This directory contains a `secrets.json` file (encrypted using git crypt). which should contain a JSON object.
- This JSON object is made available to both the home-manager user configurations in `users` & system configurations in `hosts` via the `secrets` function parameter.

### flake.nix

This is the entry point for both the `home-manager` & `NixOS`. 

#### NixOS
##### Modifications

After making any changes in the `hosts` directory, you can install the changes to the current host configuration into NixOS using the following command on the host.

```bash
sudo nixos-rebuild switch --flake .

# OR

rake nix:os:install
```

##### Formatting 

```bash
nix fmt
```

##### Upgrading 
Since we are using a `flake.lock` file, we need to update the flake using the command below and rebuild the system as normal.

```bash
# TO BE RUN FROM THE ROOT OF THIS CLONED REPOSITORY
nix flake update

# OR

rake nix:flake:update
```


#### Home-Manager
##### Modifications

Any modifications to the `nixos/users` directory can be installed using this `home-manager` command

```bash
home-manager switch --flake './nixos' -j 4 --impure

# OR 

rake nix:home:install
```

* `--impure` flag is required because nixGL uses `builtins.currentTime` as an impure parameter to force the rebuild on each access.
