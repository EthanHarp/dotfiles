{ pkgs, ... }: {
  home-manager.users.ethan = {
    home.stateVersion = "23.05";
    
    programs = {
      waybar = {
        enable = true;
        package = pkgs.waybar.overrideAttrs (oldAttrs: {
            mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
        });
	settings = [{
	  layer = "top";
	  position = "right";
	  margin = "12 12 0 12";
      spacing = 6;
	  modules-left = ["battery" "network" "custom/io" "custom/bluetooth" "custom/power" "custom/dnd" "idle_inhibitor" "tray"];
	  modules-center = ["clock" ];
	  modules-right = ["wlr/workspaces"];
	  "battery" = {
		states = {
            # good = 95;
            warning = 30;
            critical = 15;
        };
        format = "{capacity}%";
        #format-charging = "{capacity}^";
        #format-plugged = "{capacity}^";
        #format-alt = "{time} {icon}";
        # format-good = ""; # An empty format will hide the module
        # format-full = "";
        #format-icons = ["" "" "" "" ""];
	  };
	  "network" = {
		format = "";
        format-wifi = "";
        format-ethernet = "";
        tooltip-format = "{ifname} via {gwaddr} ";
        format-linked = "{ifname} (No IP) ";
        format-disconnected = "⚠";
#        format-alt = "{ifname}: {ipaddr}/{cidr}";
        on-click = "bash /home/ethan/.config/rofi/rofi-network-manager &";
        #on-click = "${pkgs.rofi-wifi-menu-packages.rofi-wifi-menu}/bin/rofi-wifi-menu";
	  };
      "custom/io" = {
        format = "";
      };
      "custom/bluetooth" = {
        format = "";
        #on-click = "rofi-bluetooth-unstable";
        on-click = "bash $HOME/.config/rofi/rofi-bluetooth -theme ~/.config/rofi/bluetooth.rasi";
        tooltip = false;
      };
      "custom/power" = {
        format = "";
        #on-click = "rofi -show power-menu -modi power-menu:rofi-power-menu";
        on-click = "rofi -show power-menu -modi power-menu:rofi-power-menu -theme ~/.config/rofi/powermenu.rasi";
        #
        tooltip = false;
      };
      "custom/dnd" = {
        format = "";
      };
	  "idle_inhibitor" = {
		format = "{icon}";
        format-icons = {
            activated = "";
            deactivated = "";
        };
	  };
	  "tray" =  {
	    icon-size = 15;
	    spacing = 6;
	    show-passive-item = true;
	  };
	  "clock" = {
        format = "{:%H\n%M}";
        tooltip-format = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
        today-format = "<span color='#ff6699'><b><u>{}</u></b></span>";
	  };
	  "clock#date" = {
		tooltip-format = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
		format = "{:%d-%m-%Y}";
	  };
	  "wlr/workspaces" = {
		on-click = "activate";
		all-outputs = true;
		format = "{icon}";
		formate-icons = {
			active = "";
           default = "";
		};
	  };
	}];
	style = ''
	  * {
    /* `otf-font-awesome` is required to be installed for icons */
    font-family: FontAwesome, Roboto, Helvetica, Arial, sans-serif;
    font-size: 13px;
}

window#waybar {
    background-color: transparent;
    color: #ffffff;
    transition-property: background-color;
    transition-duration: .5s;
}

window#waybar.hidden {
    opacity: 0.2;
}

/*
window#waybar.empty {
    background-color: transparent;
}
window#waybar.solo {
    background-color: #FFFFFF;
}
*/
.modules-right {
    background-color: #3F3F3F;
    margin: 2px 10px 0 0;
    border: none;
    border-radius: 20px;
}
.modules-left {
    background-color: #3F3F3F;
    margin: 2px 10px 0 0;
    border: none;
    border-radius: 20px;
}

.modules-center {
    background-color: #3F3F3F;
    margin: 2px 10px 0 0;
    border: none;
    border-radius: 20px;
}

window#waybar.termite {
    background-color: #3F3F3F;
}

window#waybar.chromium {
    background-color: #000000;
    border: none;
}

#workspaces button {
    padding: 0 5px;
    background-color: transparent;
    color: #ffffff;
    /* Use box-shadow instead of border so the text isn't offset */
    /*box-shadow: inset 0 -3px transparent;*/
    /* Avoid rounded borders under each workspace name */
    border: none;
    border-radius: 20px;
    margin: 2px;
}

/* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
#workspaces button:hover {
    background: rgba(0, 0, 0, 0.2);
    box-shadow: inset 0 -3px #ffffff;
}

#workspaces button.active {
    background-color: #ffffff;
    color: #000000
}

#workspaces button.urgent {
    background-color: #eb4d4b;
}

#mode {
    background-color: #64727D;
    border-bottom: 3px solid #ffffff;
}

#clock,
#battery,
#cpu,
#memory,
#disk,
#temperature,
#backlight,
#network,
#pulseaudio,
#custom-media,
#tray,
#mode,
#idle_inhibitor,
#mpd {
    padding: 0 10px;
    color: #ffffff;
}

#window {
    background-color: transparent;
}
#workspaces {
    margin: 0 4px;
}

/* If workspaces is the leftmost module, omit left margin */
.modules-left > widget:first-child > #workspaces {
    margin-left: 0;
}

/* If workspaces is the rightmost module, omit right margin */
.modules-right > widget:last-child > #workspaces {
    margin-right: 0;
}

#clock {
    background-color: transparent;
}

#battery {
    background-color: transparent;
    color: #ffffff;
}

#battery.charging, #battery.plugged {
    color: #ffffff;
    background-color: transparent;
}

@keyframes blink {
    to {
        background-color: #ffffff;
        color: #000000;
    }
}

#battery.critical:not(.charging) {
    background-color: transparent;
    color: #ffffff;
}

label:focus {
    background-color: #000000;
}

#cpu {
    background-color: #2ecc71;
    color: #000000;
}

#memory {
    background-color: #9b59b6;
}

#disk {
    background-color: #964B00;
}

#backlight {
    background-color: #90b1b1;
}

#network {
    background-color: transparent;
}

#network.disconnected {
    background-color: #f53c3c;
}

#pulseaudio {
    background-color: #f1c40f;
    color: #000000;
}

#pulseaudio.muted {
    background-color: #90b1b1;
    color: #2a5c45;
}

#custom-media {
    background-color: #66cc99;
    color: #2a5c45;
    min-width: 100px;
}

#custom-media.custom-spotify {
    background-color: #66cc99;
}

#custom-media.custom-vlc {
    background-color: #ffa000;
}

#temperature {
    background-color: #f0932b;
}

#temperature.critical {
    background-color: #eb4d4b;
}

#tray {
    background-color: transparent;
    border-radius: 8px;
}

#tray > .passive {
    -gtk-icon-effect: dim;
}

#tray > .needs-attention {
    -gtk-icon-effect: highlight;
    background-color: transparent;
}

#idle_inhibitor {
    background-color: transparent;
}

#idle_inhibitor.activated {
    background-color: transparent;
}



'';
      };
    };
  };
}
