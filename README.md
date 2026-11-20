<h1 align="center">Sertraline Shell</h1>

![GitHub last commit](https://img.shields.io/github/last-commit/Sirelliaxd/Sertraline-Shell?style=for-the-badge&labelColor=%2314141c&color=%23e6e6e8)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/Sirelliaxd/Sertraline-Shell?style=for-the-badge&label=REPO%20SIZE&labelColor=%2314141c&color=%23787c99)

---
My Quickshell Config 
- Bar 
- App Launcher
- Power Menu
- Volume Menu
- Network Menu (Mullvad VPN row included, see [swapping it out](Docs/Menus/NetworkDropdown.md#swapping-the-vpn))
- Bluetooth Menu
- Notification center* 
- Clipboard manager* 
- Theme switcher* 
- OSDs 
*And other essential things for a functional linux desktop.*


( Features marked with `*` are yet to be implemented/finished )
## Screenshots


- To-Do


## Installation


- To-Do

**One step needs root.** The network menu's `random mac` and `monitor mode` rows run `macchanger`
and `iw` as root through `pkexec`, so they raise a password prompt. To drop that prompt, install the
two files in `system/polkit/` as described in [Docs/PrivilegedActions.md](Docs/PrivilegedActions.md)

---
### Dependencies

<h3 align="center">Dependencies</h3>

- Designed for Hyprland [My Dots](https://github.com/Sirelliaxd/HyprlandDots) (*probably won't work properly without it*)
- *quickshell* itself, plus *Qt6* and a *Nerd Font* for the glyphs
- Volume control designed around *pipewire*
- Network menu: *networkmanager* (`nmcli`), *iproute2* (`ip`, `ss`), *curl*, *iw*, *macchanger*, *polkit* + a polkit agent
- VPN row: *mullvad* — this config reads `mullvad status` and opens the Mullvad client. Any other VPN works too, see [swapping it out](Docs/Menus/NetworkDropdown.md#swapping-the-vpn)
- Power menu and battery: *loginctl* (*elogind* or *systemd*), *upower*; the RAM readout uses *procps* (`free`)
- Network menu footer: *tor* and *i2p* (the packaged router is *i2pd*) — optional, the rows simply read `stopped` when they are not installed
- [OpenDisplay](https://opendisplay.app/docs/linux/install/) for ipad second screen button*

**Arch-based**

```bash
sudo pacman -S --needed quickshell hyprland ttf-jetbrains-mono-nerd \
  pipewire pipewire-pulse wireplumber \
  networkmanager network-manager-applet \
  iproute2 curl iw macchanger polkit hyprpolkitagent \
  upower procps-ng elogind

# the VPN client this config ships with lives in the AUR
paru -S mullvad-vpn-bin

# optional: the anonymity daemons the network menu reports on
sudo pacman -S tor i2pd
```

>[!IMPORTANT]
>For blur, keybinds and hyprland related stuff refer to [Docs](Docs/Hyprland.md)
