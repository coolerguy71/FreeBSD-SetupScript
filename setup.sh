# Function to display the menu, handle user input, and get confirmation
configure_graphics() {
    echo "What is your Graphics Provider (On AMD, currently only up to 6xxx is supported, will be updated once 7xxx support is added)? Options: Intel, AMD, Nvidia"
    read -p "Graphics Provider: " provider

    case "$provider" in
        Intel)
            provider_name="Intel"
            install_command="pkg install -y drm-kmod"
            kld_command="sysrc kld_list+=i915kms"
            ;;
        AMD)
            provider_name="AMD"
            install_command="pkg install -y drm-kmod"
            kld_command="sysrc kld_list+=amdgpu"
            ;;
        Nvidia)
            provider_name="Nvidia"
            install_command="pkg install -y nvidia-driver"
            kld_command="sysrc kld_list+=nvidia-modeset"
            ;;
        *)
            echo "Please choose between Intel, AMD, or Nvidia."
            exit 1
            ;;
    esac

    # Display the selected provider and ask for confirmation
    echo "You selected $provider_name."
    read -p "Do you want to install drivers for $provider_name? (y/n): " confirm

    case "$confirm" in
        [Yy])
            echo "Installing drivers for $provider_name..."
            eval "$install_command"
            eval "$kld_command"
            echo "Drivers installed and configured."

            # Prompt for the non-root username and add to the video group
            read -p "Enter the username of the non-root user to add to the video group: " username
            pw groupmod video -m "$username"
            echo "User $username has been added to the video group."

            ;;
        [Nn])
            echo "Installation canceled."
            exit 0
            ;;
        *)
            echo "Invalid response. Please enter y or n."
            exit 1
            ;;
    esac

    # Ask for desktop environment or Wayland compositor
    echo "Do you want to install an X-based desktop environment, or a Wayland compositor? Type 'xorg' for an X-based DE, and 'wayland' for a compositor."
    read -p "Desktop Environment/Compositor: " choice

    case "$choice" in
        xorg)
            echo "Installing Xorg..."
            pkg install -y xorg
            echo "Xorg installed."

            echo "Alright, you have the following options: Plasma Plasma-Minimal Gnome Gnome-Minimal XFCE Mate Mate-Minimal Cinnamon LXQT"
            read -p "Choose your desktop environment: " de_choice

            case "$de_choice" in
                Plasma)
                    echo "You selected KDE Plasma."
                    confirm_install "pkg install -y kde5 sddm && sysrc dbus_enable=\"YES\" && sysrc sddm_enable=\"YES\""
                    ;;
                Plasma-Minimal)
                    echo "You selected KDE Plasma Minimal."
                    confirm_install "pkg install -y plasma5-plasma konsole dolphin sddm && sysrc dbus_enable=\"YES\" && sysrc sddm_enable=\"YES\""
                    ;;
                Gnome)
                    echo "You selected GNOME."
                    confirm_install "pkg install -y gnome && sysrc dbus_enable=\"YES\" && sysrc gdm_enable=\"YES\""
                    ;;
                Gnome-Minimal)
                    echo "You selected GNOME Minimal."
                    confirm_install "pkg install -y gnome-lite gnome-terminal && sysrc dbus_enable=\"YES\" && sysrc gdm_enable=\"YES\""
                    ;;
                XFCE)
                    echo "You selected XFCE."
                    confirm_install "pkg install -y xfce lightdm lightdm-gtk-greeter && sysrc dbus_enable=\"YES\" && sysrc lightdm_enable=\"YES\""
                    ;;
                Mate)
                    echo "You selected MATE."
                    confirm_install "pkg install -y mate lightdm lightdm-gtk-greeter && sysrc dbus_enable=\"YES\" && sysrc lightdm_enable=\"YES\""
                    ;;
                Mate-Minimal)
                    echo "You selected MATE Minimal."
                    confirm_install "pkg install -y mate-base mate-terminal lightdm lightdm-gtk-greeter && sysrc dbus_enable=\"YES\" && sysrc lightdm_enable=\"YES\""
                    ;;
                Cinnamon)
                    echo "You selected Cinnamon."
                    confirm_install "pkg install -y cinnamon lightdm lightdm-gtk-greeter && sysrc dbus_enable=\"YES\" && sysrc lightdm_enable=\"YES\""
                    ;;
                LXQT)
                    echo "You selected LXQT."
                    confirm_install "pkg install -y lxqt sddm && sysrc dbus_enable=\"YES\" && sysrc sddm_enable=\"YES\""
                    ;;
                *)
                    echo "Invalid option. Please choose from the listed options."
                    exit 1
                    ;;
            esac
            ;;
        wayland)
            echo "You have the following options: Hyprland Sway SwayFX"
            read -p "Choose your Wayland compositor: " compositor_choice

            case "$compositor_choice" in
                Hyprland)
                    echo "You selected Hyprland."
                    confirm_install "pkg install -y hyprland kitty wayland seatd && sysrc seatd_enable=\"YES\" && sysrc dbus_enable=\"YES\" && service seatd start"
                    ;;
                Sway)
                    echo "You selected Sway."
                    confirm_install "pkg install -y sway foot wayland seatd && sysrc seatd_enable=\"YES\" && sysrc dbus_enable=\"YES\" && service seatd start"
                    ;;
                SwayFX)
                    echo "You selected SwayFX."
                    confirm_install "pkg install -y swayfx foot wayland seatd && sysrc seatd_enable=\"YES\" && sysrc dbus_enable=\"YES\" && service seatd start"
                    ;;
                *)
                    echo "Invalid option. Please choose from the listed options."
                    exit 1
                    ;;
            esac
            ;;
        *)
            echo "Invalid option. Please choose 'xorg' or 'wayland'."
            exit 1
            ;;
    esac
}
