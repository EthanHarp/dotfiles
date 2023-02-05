{ pkgs, ... }: {
  home-manager.users.ethan = {
    home.stateVersion = "23.05";

    xdg.configFile = 
      let
        rofi-theme = ''
          configuration {
          	font: "Noto Sans Semi-bold 11";
          	me-select-entry: "MouseSecondary";
          	me-accept-entry: "MousePrimary";
            hover-select: true;
            location: 3;
          }
          window {
            x-offset: -12px;
            y-offset: 12px;
            border-radius: 12px;
          }
          * {
            background: #0a0a0a;
            foreground: #b0b0b0;
          }
          entry {
            padding: 12px 12px 0px 12px;
          }
          prompt, textbox-prompt-colon, case-indicator {
            enabled: false;
          }
          mainbox, entry, listview, element {
            background-color: @background;
            text-color: @foreground;
          }
          listview {
            padding: 12px;
            spacing: 4px;
            cycle: false;
          }
          element-text selected {
            background-color: @foreground;
            text-color: @background;
            border-radius: 12px;
          }
          element-text {
            padding: 6px 12px;
            background-color: @background;
            text-color: @foreground;
          }
        '';
      in
      {
        "rofi/apps.rasi".text = ''
          ${rofi-theme}
          configuration {
            drun-display-format: "{name}";
            hover-select: false;
            location: 0;
          }
          listview {
            lines: 4;
          }
          window {
            width: 205px;
            x-offset: 0;
            y-offset: 0;
          }
        '';
        "rofi/bluetooth.rasi".text = ''
          ${rofi-theme}
          window {
            width: 175px;
          }
          listview{
            lines: 6;
          }
          entry {
            enabled: false;
          }
        '';
        "rofi/powermenu.rasi".text = ''
          ${rofi-theme}
          window {
            width: 132px;
          }
          entry {
            enabled: false;
          }
          listview {
            lines: 3;
          }
        '';
        "rofi/wlan.rasi".text = ''
          ${rofi-theme}
          configuration {
            font: "Noto Sans Mono Semi-bold 11";
          }
        '';
        "rofi/rofi-bluetooth" = {
          executable = true;
          text = ''
            #! /usr/bin/env nix-shell
            #! nix-shell -i bash -p bluetoothctl rofi
            #             __ _       _     _            _              _   _
            #  _ __ ___  / _(_)     | |__ | |_   _  ___| |_ ___   ___ | |_| |__
            # | '__/ _ \| |_| |_____| '_ \| | | | |/ _ \ __/ _ \ / _ \| __| '_ \
            # | | | (_) |  _| |_____| |_) | | |_| |  __/ || (_) | (_) | |_| | | |
            # |_|  \___/|_| |_|     |_.__/|_|\__,_|\___|\__\___/ \___/ \__|_| |_|
            #
            # Author: Nick Clyde (clydedroid)
            #
            # A script that generates a rofi menu that uses bluetoothctl to
            # connect to bluetooth devices and display status info.
            #
            # Inspired by networkmanager-dmenu (https://github.com/firecat53/networkmanager-dmenu)
            # Thanks to x70b1 (https://github.com/polybar/polybar-scripts/tree/master/polybar-scripts/system-bluetooth-bluetoothctl)
            #
            # Depends on:
            #   Arch repositories: rofi, bluez-utils (contains bluetoothctl)

            # Constants
            divider="---------"
            goback="Back"

            # Checks if bluetooth controller is powered on
            power_on() {
                if bluetoothctl show | grep -q "Powered: yes"; then
                    return 0
                else
                    return 1
                fi
            }

            # Toggles power state
            toggle_power() {
                if power_on; then
                    bluetoothctl power off
                    show_menu
                else
                    if rfkill list bluetooth | grep -q 'blocked: yes'; then
                        rfkill unblock bluetooth && sleep 3
                    fi
                    bluetoothctl power on
                    show_menu
                fi
            }

            # Checks if controller is scanning for new devices
            scan_on() {
                if bluetoothctl show | grep -q "Discovering: yes"; then
                    echo "Scan: on"
                    return 0
                else
                    echo "Scan: off"
                    return 1
                fi
            }

            # Toggles scanning state
            toggle_scan() {
                if scan_on; then
                    kill $(pgrep -f "bluetoothctl scan on")
                    bluetoothctl scan off
                    show_menu
                else
                    bluetoothctl scan on &
                    echo "Scanning..."
                    sleep 5
                    show_menu
                fi
            }

            # Checks if controller is able to pair to devices
            pairable_on() {
                if bluetoothctl show | grep -q "Pairable: yes"; then
                    echo "Pairable: on"
                    return 0
                else
                    echo "Pairable: off"
                    return 1
                fi
            }

            # Toggles pairable state
            toggle_pairable() {
                if pairable_on; then
                    bluetoothctl pairable off
                    show_menu
                else
                    bluetoothctl pairable on
                    show_menu
                fi
            }

            # Checks if controller is discoverable by other devices
            discoverable_on() {
                if bluetoothctl show | grep -q "Discoverable: yes"; then
                    echo "Discoverable: on"
                    return 0
                else
                    echo "Discoverable: off"
                    return 1
                fi
            }

            # Toggles discoverable state
            toggle_discoverable() {
                if discoverable_on; then
                    bluetoothctl discoverable off
                    show_menu
                else
                    bluetoothctl discoverable on
                    show_menu
                fi
            }

            # Checks if a device is connected
            device_connected() {
                device_info=$(bluetoothctl info "$1")
                if echo "$device_info" | grep -q "Connected: yes"; then
                    return 0
                else
                    return 1
                fi
            }

            # Toggles device connection
            toggle_connection() {
                if device_connected "$1"; then
                    bluetoothctl disconnect "$1"
                    device_menu "$device"
                else
                    bluetoothctl connect "$1"
                    device_menu "$device"
                fi
            }

            # Checks if a device is paired
            device_paired() {
                device_info=$(bluetoothctl info "$1")
                if echo "$device_info" | grep -q "Paired: yes"; then
                    echo "Paired: yes"
                    return 0
                else
                    echo "Paired: no"
                    return 1
                fi
            }

            # Toggles device paired state
            toggle_paired() {
                if device_paired "$1"; then
                    bluetoothctl remove "$1"
                    device_menu "$device"
                else
                    bluetoothctl pair "$1"
                    device_menu "$device"
                fi
            }

            # Checks if a device is trusted
            device_trusted() {
                device_info=$(bluetoothctl info "$1")
                if echo "$device_info" | grep -q "Trusted: yes"; then
                    echo "Trusted: yes"
                    return 0
                else
                    echo "Trusted: no"
                    return 1
                fi
            }

            # Toggles device connection
            toggle_trust() {
                if device_trusted "$1"; then
                    bluetoothctl untrust "$1"
                    device_menu "$device"
                else
                    bluetoothctl trust "$1"
                    device_menu "$device"
                fi
            }

            # Prints a short string with the current bluetooth status
            # Useful for status bars like polybar, etc.
            print_status() {
                if power_on; then
                    printf ''

                    paired_devices_cmd="devices Paired"
                    # Check if an outdated version of bluetoothctl is used to preserve backwards compatibility
                    if (( $(echo "$(bluetoothctl version | cut -d ' ' -f 2) < 5.65" | bc -l) )); then
                        paired_devices_cmd="paired-devices"
                    fi

                    mapfile -t paired_devices < <(bluetoothctl "$paired_devices_cmd" | grep Device | cut -d ' ' -f 2)
                    counter=0

                    for device in "$\{paired_devices[@]}"; do
                        if device_connected "$device"; then
                            device_alias=$(bluetoothctl info "$device" | grep "Alias" | cut -d ' ' -f 2-)

                            if [ $counter -gt 0 ]; then
                                printf ", %s" "$device_alias"
                            else
                                printf " %s" "$device_alias"
                            fi

                            ((counter++))
                        fi
                    done
                    printf "\n"
                else
                    echo ""
                fi
            }

            # A submenu for a specific device that allows connecting, pairing, and trusting
            device_menu() {
                device=$1

                # Get device name and mac address
                device_name=$(echo "$device" | cut -d ' ' -f 3-)
                mac=$(echo "$device" | cut -d ' ' -f 2)

                # Build options
                if device_connected "$mac"; then
                    connected="Connected: yes"
                else
                    connected="Connected: no"
                fi
                paired=$(device_paired "$mac")
                trusted=$(device_trusted "$mac")
                options="$connected\n$paired\n$trusted\n$divider\n$goback\nExit"

                # Open rofi menu, read chosen option
                chosen="$(echo -e "$options" | $rofi_command "$device_name")"

                # Match chosen option to command
                case "$chosen" in
                    "" | "$divider")
                        echo "No option chosen."
                        ;;
                    "$connected")
                        toggle_connection "$mac"
                        ;;
                    "$paired")
                        toggle_paired "$mac"
                        ;;
                    "$trusted")
                        toggle_trust "$mac"
                        ;;
                    "$goback")
                        show_menu
                        ;;
                esac
            }

            # Opens a rofi menu with current bluetooth status and options to connect
            show_menu() {
                # Get menu options
                if power_on; then
                    power="Power: on"

                    # Human-readable names of devices, one per line
                    # If scan is off, will only list paired devices
                    devices=$(bluetoothctl devices | grep Device | cut -d ' ' -f 3-)

                    # Get controller flags
                    scan=$(scan_on)
                    pairable=$(pairable_on)
                    discoverable=$(discoverable_on)

                    # Options passed to rofi
                    options="$devices\n$divider\n$power\n$scan\n$pairable\n$discoverable\nExit"
                else
                    power="Power: off"
                    options="$power\nExit"
                fi

                # Open rofi menu, read chosen option
                chosen="$(echo -e "$options" | $rofi_command "Bluetooth")"

                # Match chosen option to command
                case "$chosen" in
                    "" | "$divider")
                        echo "No option chosen."
                        ;;
                    "$power")
                        toggle_power
                        ;;
                    "$scan")
                        toggle_scan
                        ;;
                    "$discoverable")
                        toggle_discoverable
                        ;;
                    "$pairable")
                        toggle_pairable
                        ;;
                    *)
                        device=$(bluetoothctl devices | grep "$chosen")
                        # Open a submenu if a device is selected
                        if [[ $device ]]; then device_menu "$device"; fi
                        ;;
                esac
            }

            # Rofi command to pipe into, can add any options here
            rofi_command="rofi -dmenu $* -p"

            case "$1" in
                --status)
                    print_status
                    ;;
                *)
                    show_menu
                    ;;
            esac
          '';
        };
        "rofi/rofi-network-manager.conf" = {
            text = ''
                # Location
                #This sets the anchor point:
                # +---------- +
                # | 1 | 2 | 3 |
                # | 8 | 0 | 4 |
                # | 7 | 6 | 5 |
                # +-----------+
                #If you want the window to be in the upper right corner, set location to 3.
                LOCATION=0
                QRCODE_LOCATION=$LOCATION
                #X, Y Offset
                Y_AXIS=0
                X_AXIS=0
                #Use notifications or not
                # Values on / off
                NOTIFICATIONS_INIT="off"
                #Location of qrcode wifi image
                QRCODE_DIR="/tmp/"
                #WIDTH_FIX_MAIN/WIDTH_FIX_STATUS needs to be increased or decreased , if the text
                #doesn't fit or it has too much space at the end when you launch rofi-network-manager.
                #It depends on the font type and size.
                WIDTH_FIX_MAIN=1
                WIDTH_FIX_STATUS=10
            '';
        };
        "rofi/rofi-network-manager.rasi" = {
          text = ''
            configuration {
                show-icons:		false;
                sidebar-mode: 	false;
                hover-select: true;
                me-select-entry: "";
                me-accept-entry: [MousePrimary];
            }
            *{
                font: "DejaVu Sans Mono 9";			//Font
                //Colors
                foreground:#f8f8f2; 				//Text
                background:#0A1229; 				//Background
                accent:#00BCD4; 					//Highlight
                foreground-selection:@foreground; 	//Selection_fg
                background-selection:#e34039; 		//Selection_bg

                transparent:					#ffffff00;
                background-color:				@transparent;
                text-color:						@foreground;
                selected-normal-foreground:		@foreground-selection;
                normal-foreground:       		@foreground;
                alternate-normal-background:	@transparent;
                selected-urgent-foreground:  	@foreground;
                urgent-foreground:           	@foreground;
                alternate-urgent-background: 	@background;
                active-foreground:           	@accent;
                selected-active-foreground:  	@background-selection;
                alternate-normal-foreground: 	@foreground;
                alternate-active-background: 	@background;
                bordercolor:                 	@background;
                normal-background:           	@transparent;
                selected-normal-background:  	@background-selection;
                separatorcolor:              	@accent;
                urgent-background:           	@accent;
                alternate-urgent-foreground: 	@foreground;
                selected-urgent-background:  	@accent;
                alternate-active-foreground: 	@foreground;
                selected-active-background:  	@transparent;
                active-background:           	@transparent;
            }
            window {
                text-color:			@foreground;
                background-color:	@background;
                border-radius: 		6px;
                padding: 			10;
            }
            mainbox {
                border:		0;
                padding: 	0;
            }
            textbox {
                text-color: @foreground;
            }
            listview {
                spacing:		4px;
                dynamic:		true;
                fixed-height:	false;
                border:			0;
                scrollbar:		false;
                text-color:		@separatorcolor;
            }
            element {
                border:			0;
                padding:		0;
                border-radius:	4px;
            }
            element-text {
                background-color: inherit;
                text-color:       inherit;
            }
            element.normal.normal {
                text-color:			@normal-foreground;
                background-color:	@normal-background;
            }
            element.normal.urgent {
                text-color:			@urgent-foreground;
                background-color:	@urgent-background;
            }
            element.normal.active {
                text-color:			@active-foreground;
                background-color:	@active-background;
            }
            element.selected.normal {
                text-color:			@selected-normal-foreground;
                background-color:	@selected-normal-background;
            }
            element.selected.urgent {
                text-color:			@selected-urgent-foreground;
                background-color:	@selected-urgent-background;
            }
            element.selected.active {
                text-color:			@selected-active-foreground;
                background-color:	@selected-active-background;
            }
            element.alternate.normal {
                text-color:			@alternate-normal-foreground;
                background-color:	@alternate-normal-background;
            }
            element.alternate.urgent {
                text-color:			@alternate-urgent-foreground;
                background-color:	@alternate-urgent-background;
            }
            element.alternate.active {
                text-color:			@alternate-active-foreground;
                background-color:	@alternate-active-background;
            }
            mode-switcher {
                border:	0;
            }
            button selected {
                text-color:			@selected-normal-foreground;
                background-color:	@selected-normal-background;
            }
            button normal {
                text-color:	@foreground;
            }
            inputbar {
                children: [textbox-prompt-colon,entry];
            }
            textbox-prompt-colon{
                expand:	false;
                margin: 0;
                str:	":";
            }
            entry {
                placeholder:	"";
            }
          '';
        };
        "rofi/rofi-network-manager.sh" = {
          executable = true;
          text = ''
            #!/bin/bash
            # Default Values
            LOCATION=0
            QRCODE_LOCATION=$LOCATION
            Y_AXIS=0
            X_AXIS=0
            NOTIFICATIONS_INIT="off"
            QRCODE_DIR="/tmp/"
            WIDTH_FIX_MAIN=1
            WIDTH_FIX_STATUS=10
            DIR="$(cd "$(dirname "$\{BASH_SOURCE[0]}")" && pwd)"
            PASSWORD_ENTER="if connection is stored,hit enter/esc."
            WIRELESS_INTERFACES=($(nmcli device | awk '$2=="wifi" {print $1}'))
            WIRELESS_INTERFACES_PRODUCT=()
            WLAN_INT=0
            WIRED_INTERFACES=($(nmcli device | awk '$2=="ethernet" {print $1}'))
            WIRED_INTERFACES_PRODUCT=()
            function initialization() {
                source "$DIR/rofi-network-manager.conf" || source "$\{XDG_CONFIG_HOME:-$HOME/.config}/rofi/rofi-network-manager.conf"
                { [[ -f "$DIR/rofi-network-manager.rasi" ]] && RASI_DIR="$DIR/rofi-network-manager.rasi"; } || { [[ -f "$\{XDG_CONFIG_HOME:-$HOME/.config}/rofi/rofi-network-manager.rasi" ]] && RASI_DIR="$\{XDG_CONFIG_HOME:-$HOME/.config}/rofi/rofi-network-manager.rasi"; } || exit
                for i in "$\{WIRELESS_INTERFACES[@]}"; do WIRELESS_INTERFACES_PRODUCT+=("$(nmcli -f general.product device show "$i" | awk '{print $2}')"); done
                for i in "$\{WIRED_INTERFACES[@]}"; do WIRED_INTERFACES_PRODUCT+=("$(nmcli -f general.product device show "$i" | awk '{print $2}')"); done
                wireless_interface_state && ethernet_interface_state
            }
            function notification() {
                [[ "$NOTIFICATIONS_INIT" == "on" && -x "$(command -v notify-send)" ]] && notify-send -r "5" -u "normal" $1 "$2"
            }
            function wireless_interface_state() {
                [[ $\{#WIRELESS_INTERFACES[@]} -eq "0" ]] || {
                    ACTIVE_SSID=$(nmcli device status | grep "^$\{WIRELESS_INTERFACES[WLAN_INT]}." | awk '{print $4}')
                    WIFI_CON_STATE=$(nmcli device status | grep "^$\{WIRELESS_INTERFACES[WLAN_INT]}." | awk '{print $3}')
                    { [[ "$WIFI_CON_STATE" == "unavailable" ]] && WIFI_LIST="***Wi-Fi Disabled***" && WIFI_SWITCH="~Wi-Fi On" && OPTIONS="$\{WIFI_LIST}\n$\{WIFI_SWITCH}\n~Scan\n"; } || { [[ "$WIFI_CON_STATE" =~ "connected" ]] && {
                        PROMPT=$\{WIRELESS_INTERFACES_PRODUCT[WLAN_INT]}[$\{WIRELESS_INTERFACES[WLAN_INT]}]
                        WIFI_LIST=$(nmcli --fields IN-USE,SSID,SECURITY,BARS device wifi list ifname "$\{WIRELESS_INTERFACES[WLAN_INT]}" | awk -F'  +' '{ if (!seen[$2]++) print}' | sed "s/^IN-USE\s//g" | sed "/*/d" | sed "s/^ *//" | awk '$1!="--" {print}')
                        [[ "$ACTIVE_SSID" == "--" ]] && WIFI_SWITCH="~Scan\n~Manual/Hidden\n~Wi-Fi Off" || WIFI_SWITCH="~Scan\n~Disconnect\n~Manual/Hidden\n~Wi-Fi Off"
                        OPTIONS="$\{WIFI_LIST}\n$\{WIFI_SWITCH}\n"
                    }; }
                }
            }
            function ethernet_interface_state() {
                [[ $\{#WIRED_INTERFACES[@]} -eq "0" ]] || {
                    WIRED_CON_STATE=$(nmcli device status | grep "ethernet" | head -1 | awk '{print $3}')
                    { [[ "$WIRED_CON_STATE" == "disconnected" ]] && WIRED_SWITCH="~Eth On"; } || { [[ "$WIRED_CON_STATE" == "connected" ]] && WIRED_SWITCH="~Eth Off"; } || { [[ "$WIRED_CON_STATE" == "unavailable" ]] && WIRED_SWITCH="***Wired Unavailable***"; } || { [[ "$WIRED_CON_STATE" == "connecting" ]] && WIRED_SWITCH="***Wired Initializing***"; }
                    OPTIONS="$\{OPTIONS}$\{WIRED_SWITCH}\n"
                }
            }
            function rofi_menu() {
                { [[ $\{#WIRELESS_INTERFACES[@]} -gt "1" ]] && OPTIONS="$\{OPTIONS}~Change Wifi Interface\n~More Options"; } || { OPTIONS="$\{OPTIONS}~More Options"; }
                { [[ "$WIRED_CON_STATE" == "connected" ]] && PROMPT="$\{WIRED_INTERFACES_PRODUCT}[$WIRED_INTERFACES]"; } || PROMPT="$\{WIRELESS_INTERFACES_PRODUCT[WLAN_INT]}[$\{WIRELESS_INTERFACES[WLAN_INT]}]"
                SELECTION=$(echo -e "$OPTIONS" | rofi_cmd "$OPTIONS" $WIDTH_FIX_MAIN "-a 0")
                SSID=$(echo "$SELECTION" | sed "s/\s\{2,\}/\|/g" | awk -F "|" '{print $1}')
                selection_action
            }
            function rofi_cmd() {
                { [[ -n "$\{1}" ]] && WIDTH=$(echo -e "$1" | awk '{print length}' | sort -n | tail -1) && ((WIDTH += $2)) && ((WIDTH = WIDTH / 2)); } || { ((WIDTH = $2 / 2)); }
                rofi -dmenu -i -location "$LOCATION" -yoffset "$Y_AXIS" -xoffset "$X_AXIS" $3 -theme "$RASI_DIR" -theme-str 'window{width: '$WIDTH'em;}textbox-prompt-colon{str:"'$PROMPT':";}'"$4"'\'
            }
            function change_wireless_interface() {
                { [[ $\{#WIRELESS_INTERFACES[@]} -eq "2" ]] && { [[ $WLAN_INT -eq "0" ]] && WLAN_INT=1 || WLAN_INT=0; }; } || {
                    LIST_WLAN_INT=""
                    for i in "$\{!WIRELESS_INTERFACES[@]}"; do LIST_WLAN_INT=("$\{LIST_WLAN_INT[@]}$\{WIRELESS_INTERFACES_PRODUCT[$i]}[$\{WIRELESS_INTERFACES[$i]}]\n"); done
                    LIST_WLAN_INT[-1]=$\{LIST_WLAN_INT[-1]::-2}
                    CHANGE_WLAN_INT=$(echo -e "$\{LIST_WLAN_INT[@]}" | rofi_cmd "$\{LIST_WLAN_INT[@]}" $WIDTH_FIX_STATUS)
                    for i in "$\{!WIRELESS_INTERFACES[@]}"; do [[ $CHANGE_WLAN_INT == "$\{WIRELESS_INTERFACES_PRODUCT[$i]}[$\{WIRELESS_INTERFACES[$i]}]" ]] && WLAN_INT=$i && break; done
                }
                wireless_interface_state && ethernet_interface_state
                rofi_menu
            }
            function scan() {
                [[ "$WIFI_CON_STATE" =~ "unavailable" ]] && change_wifi_state "Wi-Fi" "Enabling Wi-Fi connection" "on" && sleep 2
                notification "-t 0 Wifi" "Please Wait Scanning"
                WIFI_LIST=$(nmcli --fields IN-USE,SSID,SECURITY,BARS device wifi list ifname "$\{WIRELESS_INTERFACES[WLAN_INT]}" --rescan yes | awk -F'  +' '{ if (!seen[$2]++) print}' | sed "s/^IN-USE\s//g" | sed "/*/d" | sed "s/^ *//" | awk '$1!="--" {print}')
                wireless_interface_state && ethernet_interface_state
                notification "-t 1 Wifi" "Please Wait Scanning"
                rofi_menu
            }
            function change_wifi_state() {
                notification "$1" "$2"
                nmcli radio wifi "$3"
            }
            function change_wired_state() {
                notification "$1" "$2"
                nmcli device "$3" "$4"
            }
            function net_restart() {
                notification "$1" "$2"
                nmcli networking off && sleep 3 && nmcli networking on
            }
            function disconnect() {
                ACTIVE_SSID=$(nmcli -t -f GENERAL.CONNECTION dev show "$\{WIRELESS_INTERFACES[WLAN_INT]}" | cut -d ':' -f2)
                notification "$1" "You're now disconnected from Wi-Fi network '$ACTIVE_SSID'"
                nmcli con down id "$ACTIVE_SSID"
            }
            function check_wifi_connected() {
                [[ "$(nmcli device status | grep "^$\{WIRELESS_INTERFACES[WLAN_INT]}." | awk '{print $3}')" == "connected" ]] && disconnect "Connection_Terminated"
            }
            function connect() {
                check_wifi_connected
                notification "-t 0 Wi-Fi" "Connecting to $1"
                { [[ $(nmcli dev wifi con "$1" password "$2" ifname "$\{WIRELESS_INTERFACES[WLAN_INT]}" | grep -c "successfully activated") -eq "1" ]] && notification "Connection_Established" "You're now connected to Wi-Fi network '$1'"; } || notification "Connection_Error" "Connection can not be established"
            }
            function enter_passwword() {
                PROMPT="Enter_Password" && PASS=$(echo "$PASSWORD_ENTER" | rofi_cmd "$PASSWORD_ENTER" 4 "-password")
            }
            function enter_ssid() {
                PROMPT="Enter_SSID" && SSID=$(rofi_cmd "" 40)
            }
            function stored_connection() {
                check_wifi_connected
                notification "-t 0 Wi-Fi" "Connecting to $1"
                { [[ $(nmcli dev wifi con "$1" ifname "$\{WIRELESS_INTERFACES[WLAN_INT]}" | grep -c "successfully activated") -eq "1" ]] && notification "Connection_Established" "You're now connected to Wi-Fi network '$1'"; } || notification "Connection_Error" "Connection can not be established"
            }
            function ssid_manual() {
                enter_ssid
                [[ -n $SSID ]] && {
                    enter_passwword
                    { [[ -n "$PASS" ]] && [[ "$PASS" != "$PASSWORD_ENTER" ]] && connect "$SSID" "$PASS"; } || stored_connection "$SSID"
                }
            }
            function ssid_hidden() {
                enter_ssid
                [[ -n $SSID ]] && {
                    enter_passwword && check_wifi_connected
                    [[ -n "$PASS" ]] && [[ "$PASS" != "$PASSWORD_ENTER" ]] && {
                        nmcli con add type wifi con-name "$SSID" ssid "$SSID" ifname "$\{WIRELESS_INTERFACES[WLAN_INT]}"
                        nmcli con modify "$SSID" wifi-sec.key-mgmt wpa-psk
                        nmcli con modify "$SSID" wifi-sec.psk "$PASS"
                    } || [[ $(nmcli -g NAME con show | grep -c "$SSID") -eq "0" ]] && nmcli con add type wifi con-name "$SSID" ssid "$SSID" ifname "$\{WIRELESS_INTERFACES[WLAN_INT]}"
                    notification "-t 0 Wifi" "Connecting to $SSID"
                    { [[ $(nmcli con up id "$SSID" | grep -c "successfully activated") -eq "1" ]] && notification "Connection_Established" "You're now connected to Wi-Fi network '$SSID'"; } || notification "Connection_Error" "Connection can not be established"
                }
            }
            function interface_status() {
                local -n INTERFACES=$1 && local -n INTERFACES_PRODUCT=$2
                for i in "$\{!INTERFACES[@]}"; do
                    CON_STATE=$(nmcli device status | grep "^$\{INTERFACES[$i]}." | awk '{print $3}')
                    INT_NAME=$\{INTERFACES_PRODUCT[$i]}[$\{INTERFACES[$i]}]
                    [[ "$CON_STATE" == "connected" ]] && STATUS="$INT_NAME:\n\t$(nmcli -t -f GENERAL.CONNECTION dev show "$\{INTERFACES[$i]}" | awk -F '[:]' '{print $2}') ~ $(nmcli -t -f IP4.ADDRESS dev show "$\{INTERFACES[$i]}" | awk -F '[:/]' '{print $2}')" || STATUS="$INT_NAME: $\{CON_STATE^}"
                    echo -e "$\{STATUS}"
                done
            }
            function status() {
                OPTIONS=""
                [[ $\{#WIRED_INTERFACES[@]} -ne "0" ]] && ETH_STATUS="$(interface_status WIRED_INTERFACES WIRED_INTERFACES_PRODUCT)" && OPTIONS="$\{OPTIONS}$\{ETH_STATUS}"
                [[ $\{#WIRELESS_INTERFACES[@]} -ne "0" ]] && WLAN_STATUS="$(interface_status WIRELESS_INTERFACES WIRELESS_INTERFACES_PRODUCT)" && { [[ -n $\{OPTIONS} ]] && OPTIONS="$\{OPTIONS}\n$\{WLAN_STATUS}" || OPTIONS="$\{OPTIONS}$\{WLAN_STATUS}"; }
                ACTIVE_VPN=$(nmcli -g NAME,TYPE con show --active | awk '/:vpn/' | sed 's/:vpn.*//g')
                [[ -n $ACTIVE_VPN ]] && OPTIONS="$\{OPTIONS}\n$\{ACTIVE_VPN}[VPN]: $(nmcli -g ip4.address con show "$\{ACTIVE_VPN}" | awk -F '[:/]' '{print $1}')"
                echo -e "$OPTIONS" | rofi_cmd "$OPTIONS" $WIDTH_FIX_STATUS "" "mainbox{children:[listview];}"
            }
            function share_pass() {
                SSID=$(nmcli dev wifi show-password | grep -oP '(?<=SSID: ).*' | head -1)
                PASSWORD=$(nmcli dev wifi show-password | grep -oP '(?<=Password: ).*' | head -1)
                OPTIONS="SSID: $\{SSID}\nPassword: $\{PASSWORD}"
                [[ -x "$(command -v qrencode)" ]] && OPTIONS="$\{OPTIONS}\n~QrCode"
                SELECTION=$(echo -e "$OPTIONS" | rofi_cmd "$OPTIONS" $WIDTH_FIX_STATUS "-a -1" "mainbox{children:[listview];}")
                selection_action
            }
            function gen_qrcode() {
            DIRECTIONS=("Center" "Northwest" "North" "Northeast" "East" "Southeast" "South" "Southwest" "West")
            TMP_SSID="$\{SSID// /_}"
                [[ -e $QRCODE_DIR$TMP_SSID.png ]] || qrencode -t png -o $QRCODE_DIR$TMP_SSID.png -l H -s 25 -m 2 --dpi=192 "WIFI:S:""$SSID"";T:""$(nmcli dev wifi show-password | grep -oP '(?<=Security: ).*' | head -1)"";P:""$PASSWORD"";;"
            rofi_cmd "" "0" "" "entry{enabled:false;}window{location:"$\{DIRECTIONS[QRCODE_LOCATION]}";border-radius:6mm;padding:1mm;width:100mm;height:100mm;
                background-image:url(\"$QRCODE_DIR$TMP_SSID.png\",both);}"
            }
            function manual_hidden() {
                OPTIONS="~Manual\n~Hidden" && SELECTION=$(echo -e "$OPTIONS" | rofi_cmd "$OPTIONS" $WIDTH_FIX_STATUS "" "mainbox{children:[listview];}")
                selection_action
            }
            function vpn() {
                ACTIVE_VPN=$(nmcli -g NAME,TYPE con show --active | awk '/:vpn/' | sed 's/:vpn.*//g')
                [[ $ACTIVE_VPN ]] && OPTIONS="~Deactive $ACTIVE_VPN" || OPTIONS="$(nmcli -g NAME,TYPE connection | awk '/:vpn/' | sed 's/:vpn.*//g')"
                VPN_ACTION=$(echo -e "$OPTIONS" | rofi_cmd "$OPTIONS" "$WIDTH_FIX_STATUS" "" "mainbox {children:[listview];}")
                [[ -n "$VPN_ACTION" ]] && { { [[ "$VPN_ACTION" =~ "~Deactive" ]] && nmcli connection down "$ACTIVE_VPN" && notification "VPN_Deactivated" "$ACTIVE_VPN"; } || {
                    notification "-t 0 Activating_VPN" "$VPN_ACTION" && VPN_OUTPUT=$(nmcli connection up "$VPN_ACTION" 2>/dev/null)
                    { [[ $(echo "$VPN_OUTPUT" | grep -c "Connection successfully activated") -eq "1" ]] && notification "VPN_Successfully_Activated" "$VPN_ACTION"; } || notification "Error_Activating_VPN" "Check your configuration for $VPN_ACTION"
                }; }
            }
            function more_options() {
                OPTIONS=""
                [[ "$WIFI_CON_STATE" == "connected" ]] && OPTIONS="~Share Wifi Password\n"
                OPTIONS="$\{OPTIONS}~Status\n~Restart Network"
                [[ $(nmcli -g NAME,TYPE connection | awk '/:vpn/' | sed 's/:vpn.*//g') ]] && OPTIONS="$\{OPTIONS}\n~VPN"
                [[ -x "$(command -v nm-connection-editor)" ]] && OPTIONS="$\{OPTIONS}\n~Open Connection Editor"
                SELECTION=$(echo -e "$OPTIONS" | rofi_cmd "$OPTIONS" "$WIDTH_FIX_STATUS" "" "mainbox {children:[listview];}")
                selection_action
            }
            function selection_action() {
                case "$SELECTION" in
                "~Disconnect") disconnect "Connection_Terminated" ;;
                "~Scan") scan ;;
                "~Status") status ;;
                "~Share Wifi Password") share_pass ;;
                "~Manual/Hidden") manual_hidden ;;
                "~Manual") ssid_manual ;;
                "~Hidden") ssid_hidden ;;
                "~Wi-Fi On") change_wifi_state "Wi-Fi" "Enabling Wi-Fi connection" "on" ;;
                "~Wi-Fi Off") change_wifi_state "Wi-Fi" "Disabling Wi-Fi connection" "off" ;;
                "~Eth Off") change_wired_state "Ethernet" "Disabling Wired connection" "disconnect" "$\{WIRED_INTERFACES}" ;;
                "~Eth On") change_wired_state "Ethernet" "Enabling Wired connection" "connect" "$\{WIRED_INTERFACES}" ;;
                "***Wi-Fi Disabled***") ;;
                "***Wired Unavailable***") ;;
                "***Wired Initializing***") ;;
                "~Change Wifi Interface") change_wireless_interface ;;
                "~Restart Network") net_restart "Network" "Restarting Network" ;;
                "~QrCode") gen_qrcode ;;
                "~More Options") more_options ;;
                "~Open Connection Editor") nm-connection-editor ;;
                "~VPN") vpn ;;
                *)
                    [[ -n "$SELECTION" ]] && [[ "$WIFI_LIST" =~ .*"$SELECTION".* ]] && {
                        [[ "$SSID" == "*" ]] && SSID=$(echo "$SELECTION" | sed "s/\s\{2,\}/\|/g " | awk -F "|" '{print $3}')
                        { [[ "$ACTIVE_SSID" == "$SSID" ]] && nmcli con up "$SSID" ifname "$\{WIRELESS_INTERFACES[WLAN_INT]}"; } || {
                            [[ "$SELECTION" =~ "WPA2" ]] || [[ "$SELECTION" =~ "WEP" ]] && enter_passwword
                            { [[ -n "$PASS" ]] && [[ "$PASS" != "$PASSWORD_ENTER" ]] && connect "$SSID" "$PASS"; } || stored_connection "$SSID"
                        }
                    }
                    ;;
                esac
            }
            function main() {
                initialization && rofi_menu
            }
            main 
          '';
        };
    };
  };
}