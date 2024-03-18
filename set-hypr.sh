#!/bin/bash
### Check for yay ###

ISYAY=/sbin/yay
if [ -f "$ISYAY" ]; then
	echo -e "yay was located, moving on.\n"
	yay -Suy
else
	echo -e "yay was not located, please install yay. Exiting script.\n"
	exit
fi

read -n1 -rep 'Disable wifi powersave? (y,n)' WIFI
if [[ $WIFI == "Y" || $WIFI == "y" ]]; then
	LOC="/etc/NetworkManager/conf.d/wifi-powersave.conf"
	echo -e "The following has been added to $LOC.\n"
	echo -e "[connection]\nwifi.powersave = 2" | sudo tee -a $LOC
	echo -e "\n"
	echo -e "Restarting NetworkManager service...\n"
	sudo systemctl restart NetworkManager
	sleep 3
fi

read -n1 -rep 'Install the packages? (y,n)' INST
if [[ $INST == "Y" || $INST == "y" ]]; then
	yay -S --noconfirm hyprland kitty waybar \
		swaybg swaylock-effects wofi wlogout mako thunar \
		ttf-jetbrains-mono-nerd noto-fonts-emoji \
		polkit-gnome python-requests starship \
		swappy grim slurp pamixer brightnessctl gvfs \
		bluez bluez-utils lxappearance xfce4-settings \
		dracula-gtk-theme dracula-icons-git xdg-desktop-portal-hyprland

	# Start the bluetooth service
	echo -e "Starting the Bluetooth Service...\n"
	sudo systemctl enable --now bluetooth.service
	sleep 2

	# Clean out other portals
	echo -e "Cleaning out conflicting xdg portals...\n"
	yay -R --noconfirm xdg-desktop-portal-gnome xdg-desktop-portal-gtk
fi

read -n1 -rep 'Install Asus ROG software support? (y,n)' ROG
if [[ $ROG == "Y" || $ROG == "y" ]]; then
	echo -e "Adding Keys... \n"
	sudo pacman-key --recv-keys 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
	sudo pacman-key --finger 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
	sudo pacman-key --lsign-key 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
	sudo pacman-key --finger 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35

	LOC="/etc/pacman.conf"
	echo -e "Updating $LOC with g14 repo.\n"
	echo -e "\n[g14]\nServer = https://arch.asus-linux.org" | sudo tee -a $LOC
	echo -e "\n"
	echo -e "Update the system...\n"
	sudo pacman -Suy

	echo -e "Installing ROG pacakges...\n"
	sudo pacman -S --noconfirm asusctl supergfxctl rog-control-center
	echo -e "Activating ROG services...\n"
	sudo systemctl enable --now power-profiles-daemon.service
	sleep 2
	sudo systemctl enable --now supergfxd
	sleep 2
fi
### Copy Config Files ###
read -n1 -rep 'Copy config files? (y,n)' CFG
if [[ $CFG == "Y" || $CFG == "y" ]]; then
	echo -e "Copying config files...\n"
	cp -R hypr ~/.config/
	cp -R kitty ~/.config/
	cp -R mako ~/.config/
	cp -R waybar ~/.config/
	cp -R swaylock ~/.config/
	cp -R wofi ~/.config/

	# Set some files as exacutable
	chmod +x ~/.config/hypr/xdg-portal-hyprland
	chmod +x ~/.config/waybar/scripts/waybar-wttr.py
fi

##FUTURE CONFIG OF bash and prompt
#;)

exec Hyprland
