{ pkgs, ... }: {
  home-manager.users.ethan = {
    home.packages = with pkgs; [ 
      #system
      font-awesome 
      swaybg 
      udiskie 
      rofi-wayland 
      pamixer
      brightnessctl
      wob
      swayidle
      swaylock-effects
      rofi-bluetooth
      rofi-power-menu
      #terminal art
      cbonsai
      pipes
      asciiquarium
      neofetch

      waydroid 
      xfce.thunar 
      ranger 
      electron-mail 
      freetube 
      obsidian 
      kitty  
      neovim 
      discord
      
      libsForQt5.polkit-kde-agent
      
      qt6.qtwayland
      qt6.qtbase
      wireplumber
      slurp
      qpwgraph
      obs-studio
      vlc
      
      virt-manager
      bitwarden
      wget
      signal-desktop
      slack
      teams
      brave

      cryptomator
      megasync
      xdg-utils

    ];
    home.stateVersion = "23.05";
    
    programs = {
      vscode = {
        enable = true;
	      package = pkgs.vscodium;
	      extensions = with pkgs.vscode-extensions; [
            bbenoist.nix
	      ];
      };
      git = {
        enable = true;
        userName = "EthanHarp";
        userEmail = "eharp12@protonmail.com";
      };
      gh = {
        enable = true;
      };
      mako = {
        enable = true;
      };
      librewolf = {
        enable = true;
      };
    };
    services = {
      
    };
  };
}
