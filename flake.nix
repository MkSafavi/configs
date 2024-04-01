{
  description = "NixOS configurations";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-yuzu.url =
      "github:nixos/nixpkgs/f20a0c955555fb68cfc72886d7476de2aacd1b4e"; #https://github.com/NixOS/nixpkgs/pull/295587
    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, nixpkgs-yuzu, home-manager, musnix, ... }:
    let
      system = "x86_64-linux";
      mkMachine = machineModules:
        nixpkgs.lib.nixosSystem rec {
          inherit system;
          specialArgs = {
            inherit nixpkgs;
            pkgs-yuzu = import nixpkgs-yuzu {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = [
            system/configuration.nix
            home-manager.nixosModules.default
            {
              home-manager = {
                extraSpecialArgs = specialArgs;
                # home-manager uses the global pkgs that is configured via the system level nixpkgs options. this is necessary for allowing unfree apps on home-manager
                useGlobalPkgs = true;
                # packages will be installed to /etc/profiles instead of $HOME/.nix-profile
                useUserPackages = true;
              };
            }

          ] ++ machineModules;
        };
    in {
      nixosConfigurations = {
        t1000 = mkMachine [
          system/t1000/configuration.nix
          musnix.nixosModules.musnix
          home-manager.nixosModules.home-manager
          {
            home-manager.users.mk = import home/mk.nix;
          }
        ];
        t800 = mkMachine [
          system/t800/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.users.mk = import home/home.nix;
          }
        ];

      };
    };
}
