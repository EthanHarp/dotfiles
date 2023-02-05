{ pkgs, ... }: {
  home-manager.users.ethan = {
    home.stateVersion = "23.05";
    xdg.configFile."discord/settings.json".text = ''
      {
        "SKIP_HOST_UPDATE": true
      }
    '';
    xdg.configFile."retardMenu".text = ''
      Q - quit window
      W - wifi menu
      E - exit hyprland
      R - retard menu
      T - terminal
      A - audio menu
      S - screenshot
      D - do not disturb
      F - file manager
      G - gateway
      Z - zzzzz toggle
      X - Xterminate computer
      C - change split
      V - vroosh I'm floating
      B - bluetooth menu
    '';
    xdg.mimeApps = {
      enable = true;
      associations.added = {
        "inode/mount-point" = ["xfce.thunar.desktop"];
      };
      defaultApplications = {
        "inode/mount-point" = ["xfce.thunar.desktop"];
      };
    };
    xdg.configFile."ranger/rc.conf".text = ''
      set preview_images true
      set preview_images_method kitty
    '';
  };
}