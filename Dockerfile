FROM nixos/nix

# Set up environment for building the NixOS configuration
RUN nix-channel --update

# Copy your flake files to the Docker image
COPY . /workspace
WORKDIR /workspace

RUN nix --extra-experimental-features flakes --extra-experimental-features nix-command flake lock
CMD nix --extra-experimental-features flakes --extra-experimental-features nix-command build '.#nixosConfigurations.athena0.config.system.build.toplevel' --no-link
