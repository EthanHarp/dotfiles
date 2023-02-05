{
  description = "A very basic flake";

  inputs = {
   
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };  
    hyprwm-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sway-audio-idle-inhibit = {
      url = "github:ErikReider/SwayAudioIdleInhibit";
      flake = false;
    };
    rofi-wifi-menu = {
      url = "github:zbaylin/rofi-wifi-menu";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, hyprwm-contrib, sway-audio-idle-inhibit, rofi-wifi-menu }: 
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = { allowUnfree = true; };
    };
    lib = nixpkgs.lib;
  in {
    nixosConfigurations = {
      nixos = lib.nixosSystem {
        inherit system;
	modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./hypr.nix
          ./home.nix
          ./waybar.nix
          ./misc.nix
          ./greetd.nix
          ./rofi.nix
          ./kitty.nix
          hyprland.nixosModules.default {
            programs.hyprland.enable = true;
          }
        ];
        specialArgs =
            let
              pkgs = import nixpkgs {
                config = { allowUnfree = true; };
                inherit system;
                overlays = [
                  (self: super: {
                    hyprwm-contrib-packages = hyprwm-contrib.packages.${system};
                    sway-audio-idle-inhibit-packages = sway-audio-idle-inhibit.packages.${system};
                    #rofi-wifi-menu-packages = rofi-wifi-menu.packages.${system};
                  })
                ];
              };
        in
            {
              inherit pkgs;
            };
      };
    };
    homeConfigurations."ethan@nixos" = home-manager.lib.homeManagerConfiguration {
      
      modules = [
        
        hyprland.homeManagerModules.default {
          wayland.windowManager.hyprland.enable = true;
        }
        
      ];
    };
  };
}
