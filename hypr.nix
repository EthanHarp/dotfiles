{ pkgs, ... }: {
  home-manager.users.ethan = {
    home.stateVersion = "23.05";
    xdg.configFile."hypr/hyprland.conf".text = ''


      monitor=,preferred,auto,1


      # See https://wiki.hyprland.org/Configuring/Keywords/ for more

      # Execute your favorite apps at launch
      # exec-once = waybar & hyprpaper & firefox
      exec-once = waybar
      exec-once = mako
      #exec-once = thunar --daemon
      exec-once = udiskie -s -n
      exec-once = swaybg -m center -i ~/.config/dotfiles/wallpaper.png
      exec-once= systemctl --user import-environment DISPLAY WAYLAND_DISPLAY hyperctl
      $WOBSOCK=$XDG_RUNTIME_DIR/wob.sock
      exec-once= rm -f $WOBSOCK && mkfifo $WOBSOCK && tail -f $WOBSOCK | wob
      exec-once=swayidle -w timeout 60 './lock.sh' timeout 80 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' before-sleep './lock.sh'
      exec-once=sway-audio-idle-inhibit
      # Source a file (multi-file configs)
      # source = ~/.config/hypr/myColors.conf

      # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
      input {
          kb_layout = us
          kb_variant =
          kb_model =
          kb_options =
          kb_rules =

          follow_mouse = 1

          touchpad {
              natural_scroll = yes
          }

          sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
      }

      misc {
          disable_hyprland_logo = true
      }

      general {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more

          gaps_in = 5
          gaps_out = 20
          border_size = 2
          col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
          col.inactive_border = rgba(595959aa)

          layout = dwindle
      }

      decoration {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more

          rounding = 10
          blur = yes
          blur_size = 3
          blur_passes = 1
          blur_new_optimizations = on

          drop_shadow = yes
          shadow_range = 4
          shadow_render_power = 3
          col.shadow = rgba(1a1a1aee)
      }

      animations {
          enabled = yes

          # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

          bezier = myBezier, 0.05, 0.9, 0.1, 1.05

          animation = windows, 1, 7, myBezier
          animation = windowsOut, 1, 7, default, popin 80%
          animation = border, 1, 10, default
          animation = fade, 1, 7, default
          animation = workspaces, 1, 6, default
      }

      dwindle {
          # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
          pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          preserve_split = yes # you probably want this
      }

      master {
          # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
          new_is_master = true
      }

      gestures {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          workspace_swipe = off
      }

      # Example per-device config
      # See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
      device:epic mouse V1 {
          sensitivity = -0.5
      }

      # Example windowrule v1
      # windowrule = float, ^(kitty)$
      # Example windowrule v2
      # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
      # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more


      # See https://wiki.hyprland.org/Configuring/Keywords/ for more
      $mainMod = SUPER
      # bind = $mainMod, P, pseudo, # dwindle
      # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
      bind = $mainMod, Q, killactive, 
      #bind = $mainMod, W, exec, wifi
      bind = $mainMod, E, exit, 
      bind = $mainMod, R, exec, kitty nvim ~/.config/retardMenu
      bind = $mainMod, T, exec, kitty
      #bind = $mainMod, A, exec, audio
      bind = $mainMod, S, exec,${pkgs.hyprwm-contrib-packages.grimblast}/bin/grimblast --notify copysave area ~/pictures/screenshots/$(date +'%s_screenshot.png')
      #bind = $mainMod, D, exec, do not disturb
      bind = $mainMod, F, exec, thunar
      bind = $mainMod, G, exec, librewolf
      #bind = $mainMod, B, exec, bluetooth
      #bind = $mainMod, Z, exec, idle inhibitor
      #bind = $mainMod, X, exec, powermenu
      bind = $mainMod, C, togglesplit, # dwindle
      bind = $mainMod, V, togglefloating, 
      bind = $mainMod, Space, exec, rofi -show drun -theme ~/.config/rofi/apps.rasi

      # Move focus with mainMod + arrow keys
      bind = $mainMod, left, movefocus, l
      bind = $mainMod, right, movefocus, r
      bind = $mainMod, up, movefocus, u
      bind = $mainMod, down, movefocus, d

      # Switch workspaces with mainMod + [0-9]
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3
      bind = $mainMod SHIFT, 4, movetoworkspace, 4
      bind = $mainMod SHIFT, 5, movetoworkspace, 5
      bind = $mainMod SHIFT, 6, movetoworkspace, 6
      bind = $mainMod SHIFT, 7, movetoworkspace, 7
      bind = $mainMod SHIFT, 8, movetoworkspace, 8
      bind = $mainMod SHIFT, 9, movetoworkspace, 9
      bind = $mainMod SHIFT, 0, movetoworkspace, 10

      # Scroll through existing workspaces with mainMod + scroll
      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow

      bind=,XF86AudioRaiseVolume,exec,pamixer -ui 5 && pamixer --get-volume > $WOBSOCK
      bind=,XF86AudioLowerVolume,exec,pamixer -ud 5 && pamixer --get-volume > $WOBSOCK
      bind=,XF86AudioMute,exec,pamixer --toggle-mute && ( [ "$(pamixer --get-mute)" = "true" ] && echo 0 > $WOBSOK ) || pamixer --get-volume > $WOBSOCK

      bind=,XF86MonBrightnessUp,exec,brightnessctl set +5% | sed -En 's/.*\(([0-9]+)%\).*/\1/p' > $WOBSOCK 
      bind=,XF86MonBrightnessDown,exec,brightnessctl set 5%- | sed -En 's/.*\(([0-9]+)%\).*/\1/p' > $WOBSOCK 
    '';
  };
}