<h1 align="center">Sertraline Shell</h1>
<img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/Sirelliaxd/Sertraline-Shell?style=for-the-badge&labelColor=%2314141c&color=%23e6e6e8"> <img alt="GitHub code size in bytes" src="https://img.shields.io/github/languages/code-size/Sirelliaxd/Sertraline-Shell?style=for-the-badge&label=REPO%20SIZE&labelColor=%2314141c&color=%23787c99">

---
My Quickshell Config 
- Bar 
- App Launcher* 
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


---
### Dependencies
<h3 align="center">Dependencies</h3>

- Designed for Hyprland (*probably wont work properly without it*)
- Volume control designed around *pipewire*
- [OpenDisplay](https://opendisplay.app/docs/linux/install/) for ipad second screen button*

~ For blur to work on the top notch this needs to be included in hyprland config:
```
hl.layer_rule({
	match = { namespace = "quickshell-notch" },

	blur = true,
	ignore_alpha = 0.2,
})
```
