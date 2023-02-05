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
        "rofi/config.rasi".text = ''
          ${rofi-theme}
        '';
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
        "rofi/rofi-power-menu" = {
          executable = true;
          text = ''
            #!/usr/bin/env bash
            # /usr/bin/env nix-shell
            # nix-shell -i bash

            # This script defines just a mode for rofi instead of being a self-contained
            # executable that launches rofi by itself. This makes it more flexible than
            # running rofi inside this script as now the user can call rofi as one pleases.
            # For instance:
            #
            #   rofi -show powermenu -modi powermenu:./rofi-power-menu
            #
            # See README.md for more information.

            set -e
            set -u

            # All supported choices
            all=(shutdown reboot suspend hibernate logout lockscreen)

            # By default, show all (i.e., just copy the array)
            show=("$\{all[@]}")

            declare -A texts
            texts[lockscreen]="lock screen"
            texts[switchuser]="switch user"
            texts[logout]="log out"
            texts[suspend]="suspend"
            texts[hibernate]="hibernate"
            texts[reboot]="reboot"
            texts[shutdown]="shut down"

            declare -A icons
            icons[lockscreen]="\uf023"
            icons[switchuser]="\uf518"
            icons[logout]="\uf842"
            icons[suspend]="\uf9b1"
            icons[hibernate]="\uf7c9"
            icons[reboot]="\ufc07"
            icons[shutdown]="\uf011"
            icons[cancel]="\u00d7"

            declare -A actions
            actions[lockscreen]="loginctl lock-session $\{XDG_SESSION_ID-}"
            #actions[switchuser]="???"
            actions[logout]="loginctl terminate-session $\{XDG_SESSION_ID-}"
            actions[suspend]="systemctl suspend"
            actions[hibernate]="systemctl hibernate"
            actions[reboot]="systemctl reboot"
            actions[shutdown]="systemctl poweroff"

            # By default, ask for confirmation for actions that are irreversible
            confirmations=(reboot shutdown logout)

            # By default, no dry run
            dryrun=false
            showsymbols=true

            function check_valid {
                option="$1"
                shift 1
                for entry in "$\{@}"
                do
                    if [ -z "$\{actions[$entry]+x}" ]
                    then
                        echo "Invalid choice in $1: $entry" >&2
                        exit 1
                    fi
                done
            }

            # Parse command-line options
            parsed=$(getopt --options=h --longoptions=help,dry-run,confirm:,choices:,choose:,symbols,no-symbols --name "$0" -- "$@")
            if [ $? -ne 0 ]; then
                echo 'Terminating...' >&2
                exit 1
            fi
            eval set -- "$parsed"
            unset parsed
            while true; do
                case "$1" in
                    "-h"|"--help")
                        echo "rofi-power-menu - a power menu mode for Rofi"
                        echo
                        echo "Usage: rofi-power-menu [--choices CHOICES] [--confirm CHOICES]"
                        echo "                       [--choose CHOICE] [--dry-run] [--symbols|--no-symbols]"
                        echo
                        echo "Use with Rofi in script mode. For instance, to ask for shutdown or reboot:"
                        echo
                        echo "  rofi -show menu -modi \"menu:rofi-power-menu --choices=shutdown/reboot\""
                        echo
                        echo "Available options:"
                        echo "  --dry-run          Don't perform the selected action but print it to stderr."
                        echo "  --choices CHOICES  Show only the selected choices in the given order. Use / "
                        echo "                     as the separator. Available choices are lockscreen, logout,"
                        echo "                     suspend, hibernate, reboot and shutdown. By default, all"
                        echo "                     available choices are shown."
                        echo "  --confirm CHOICES  Require confirmation for the gives choices only. Use / as"
                        echo "                     the separator. Available choices are lockscreen, logout,"
                        echo "                     suspend, hibernate, reboot and shutdown. By default, only"
                        echo "                     irreversible actions logout, reboot and shutdown require"
                        echo "                     confirmation."
                        echo "  --choose CHOICE    Preselect the given choice and only ask for a confirmation"
                        echo "                     (if confirmation is set to be requested). It is strongly"
                        echo "                     recommended to combine this option with --confirm=CHOICE"
                        echo "                     if the choice wouldn't require confirmation by default."
                        echo "                     Available choices are lockscreen, logout, suspend,"
                        echo "                     hibernate, reboot and shutdown."
                        echo "  --[no-]symbols     Show Unicode symbols or not. Requires a font with support"
                        echo "                     for the symbols. Use, for instance, fonts from the"
                        echo "                     Nerdfonts collection. By default, they are shown"
                        echo "  -h,--help          Show this help text."
                        exit 0
                        ;;
                    "--dry-run")
                        dryrun=true
                        shift 1
                        ;;
                    "--confirm")
                        IFS='/' read -ra confirmations <<< "$2"
                        check_valid "$1" "$\{confirmations[@]}"
                        shift 2
                        ;;
                    "--choices")
                        IFS='/' read -ra show <<< "$2"
                        check_valid "$1" "$\{show[@]}"
                        shift 2
                        ;;
                    "--choose")
                        # Check that the choice is valid
                        check_valid "$1" "$2"
                        selectionID="$2"
                        shift 2
                        ;;
                    "--symbols")
                        showsymbols=true
                        shift 1
                        ;;
                    "--no-symbols")
                        showsymbols=false
                        shift 1
                        ;;
                    "--")
                        shift
                        break
                        ;;
                    *)
                        echo "Internal error" >&2
                        exit 1
                        ;;
                esac
            done

            # Define the messages after parsing the CLI options so that it is possible to
            # configure them in the future.

            function write_message {
                icon="<span font_size=\"medium\">$1</span>"
                text="<span font_size=\"medium\">$2</span>"
                if [ "$showsymbols" = "true" ]
                then
                    echo -n "\u200e$icon \u2068$text\u2069"
                else
                    echo -n "$text"
                fi
            }

            function print_selection {
                echo -e "$1" | $(read -r -d '\' entry; echo "echo $entry")
            }

            declare -A messages
            declare -A confirmationMessages
            for entry in "$\{all[@]}"
            do
                messages[$entry]=$(write_message "$\{icons[$entry]}" "$\{texts[$entry]^}")
            done
            for entry in "$\{all[@]}"
            do
                confirmationMessages[$entry]=$(write_message "$\{icons[$entry]}" "Yes, $\{texts[$entry]}")
            done
            confirmationMessages[cancel]=$(write_message "$\{icons[cancel]}" "No, cancel")

            if [ $# -gt 0 ]
            then
                # If arguments given, use those as the selection
                selection="$\{@}"
            else
                # Otherwise, use the CLI passed choice if given
                if [ -n "$\{selectionID+x}" ]
                then
                    selection="$\{messages[$selectionID]}"
                fi
            fi

            # Don't allow custom entries
            echo -e "\0no-custom\x1ftrue"
            # Use markup
            echo -e "\0markup-rows\x1ftrue"

            if [ -z "$\{selection+x}" ]
            then
                echo -e "\0prompt\x1fPower menu"
                for entry in "$\{show[@]}"
                do
                    echo -e "$\{messages[$entry]}\0icon\x1f$\{icons[$entry]}"
                done
            else
                for entry in "$\{show[@]}"
                do
                    if [ "$selection" = "$(print_selection "$\{messages[$entry]}")" ]
                    then
                        # Check if the selected entry is listed in confirmation requirements
                        for confirmation in "$\{confirmations[@]}"
                        do
                            if [ "$entry" = "$confirmation" ]
                            then
                                # Ask for confirmation
                                echo -e "\0prompt\x1fAre you sure"
                                echo -e "$\{confirmationMessages[$entry]}\0icon\x1f$\{icons[$entry]}"
                                echo -e "$\{confirmationMessages[cancel]}\0icon\x1f$\{icons[cancel]}"
                                exit 0
                            fi
                        done
                        # If not, then no confirmation is required, so mark confirmed
                        selection=$(print_selection "$\{confirmationMessages[$entry]}")
                    fi
                    if [ "$selection" = "$(print_selection "$\{confirmationMessages[$entry]}")" ]
                    then
                        if [ $dryrun = true ]
                        then
                            # Tell what would have been done
                            echo "Selected: $entry" >&2
                        else
                            # Perform the action
                            $\{actions[$entry]}
                        fi
                        exit 0
                    fi
                    if [ "$selection" = "$(print_selection "$\{confirmationMessages[cancel]}")" ]
                    then
                        # Do nothing
                        exit 0
                    fi
                done
                # The selection didn't match anything, so raise an error
                echo "Invalid selection: $selection" >&2
                exit 1
            fi
          '';
        };
        "rofi/rofi-wifi-menu" = {
          executable = true;
          text = ''
            #! /usr/bin/env nix-shell
            #! nix-shell -i bash -p nmcli

            # Starts a scan of available broadcasting SSIDs
            # nmcli dev wifi rescan

            DIR="$( cd "$( dirname "$\{BASH_SOURCE[0]}" )" && pwd )"

            FIELDS=SSID,SECURITY
            POSITION=2
            YOFF=0
            XOFF=0
            FONT="DejaVu Sans Mono 8"

            #if [ -r "$DIR/config" ]; then
            #    source "$DIR/config"
            #elif [ -r "$HOME/.config/rofi/wifi" ]; then
            #    source "$HOME/.config/rofi/wifi"
            #else
            #    echo "WARNING: config file not found! Using default values."
            #fi

            LIST=$(nmcli --fields "$FIELDS" device wifi list | sed '/^--/d')
            # For some reason rofi always approximates character width 2 short... hmmm
            RWIDTH=$(($(echo "$LIST" | head -n 1 | awk '{print length($0); }')+2))
            # Dynamically change the height of the rofi menu
            LINENUM=$(echo "$LIST" | wc -l)
            # Gives a list of known connections so we can parse it later
            KNOWNCON=$(nmcli connection show)
            # Really janky way of telling if there is currently a connection
            CONSTATE=$(nmcli -fields WIFI g)

            CURRSSID=$(LANGUAGE=C nmcli -t -f active,ssid dev wifi | awk -F: '$1 ~ /^yes/ {print $2}')

            if [[ ! -z $CURRSSID ]]; then
                HIGHLINE=$(echo  "$(echo "$LIST" | awk -F "[  ]{2,}" '{print $1}' | grep -Fxn -m 1 "$CURRSSID" | awk -F ":" '{print $1}') + 1" | bc )
            fi

            # HOPEFULLY you won't need this as often as I do
            # If there are more than 8 SSIDs, the menu will still only have 8 lines
            if [ "$LINENUM" -gt 8 ] && [[ "$CONSTATE" =~ "enabled" ]]; then
                LINENUM=8
            elif [[ "$CONSTATE" =~ "disabled" ]]; then
                LINENUM=1
            fi


            if [[ "$CONSTATE" =~ "enabled" ]]; then
                TOGGLE="toggle off"
            elif [[ "$CONSTATE" =~ "disabled" ]]; then
                TOGGLE="toggle on"
            fi



            CHENTRY=$(echo -e "$TOGGLE\nmanual\n$LIST" | uniq -u | rofi -dmenu -p "Wi-Fi SSID: " -lines "$LINENUM" -a "$HIGHLINE" -location "$POSITION" -yoffset "$YOFF" -xoffset "$XOFF" -font "$FONT" -width -"$RWIDTH")
            #echo "$CHENTRY"
            CHSSID=$(echo "$CHENTRY" | sed  's/\s\{2,\}/\|/g' | awk -F "|" '{print $1}')
            #echo "$CHSSID"

            # If the user inputs "manual" as their SSID in the start window, it will bring them to this screen
            if [ "$CHENTRY" = "manual" ] ; then
                # Manual entry of the SSID and password (if appplicable)
                MSSID=$(echo "enter the SSID of the network (SSID,password)" | rofi -dmenu -p "Manual Entry: " -font "$FONT" -lines 1)
                # Separating the password from the entered string
                MPASS=$(echo "$MSSID" | awk -F "," '{print $2}')

                #echo "$MSSID"
                #echo "$MPASS"

                # If the user entered a manual password, then use the password nmcli command
                if [ "$MPASS" = "" ]; then
                    nmcli dev wifi con "$MSSID"
                else
                    nmcli dev wifi con "$MSSID" password "$MPASS"
                fi

            elif [ "$CHENTRY" = "toggle on" ]; then
                nmcli radio wifi on

            elif [ "$CHENTRY" = "toggle off" ]; then
                nmcli radio wifi off

            else

                # If the connection is already in use, then this will still be able to get the SSID
                if [ "$CHSSID" = "*" ]; then
                    CHSSID=$(echo "$CHENTRY" | sed  's/\s\{2,\}/\|/g' | awk -F "|" '{print $3}')
                fi

                # Parses the list of preconfigured connections to see if it already contains the chosen SSID. This speeds up the connection process
                if [[ $(echo "$KNOWNCON" | grep "$CHSSID") = "$CHSSID" ]]; then
                    nmcli con up "$CHSSID"
                else
                    if [[ "$CHENTRY" =~ "WPA2" ]] || [[ "$CHENTRY" =~ "WEP" ]]; then
                        WIFIPASS=$(echo "if connection is stored, hit enter" | rofi -dmenu -p "password: " -lines 1 -font "$FONT" )
                    fi
                    nmcli dev wifi con "$CHSSID" password "$WIFIPASS"
                fi

            fi
          '';
        };
    };
  };
}