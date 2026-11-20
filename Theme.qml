pragma Singleton

import Quickshell
import QtQuick

Singleton {
    // Colors

    readonly property bool backgroundTransparency: true  // false -> menus draw the opaque fill
    // -------
    readonly property color background: backgroundTransparency ? bgTs : bg  // fill, follows the flag above
    readonly property color bg: "#14141c"  // opaque fill
    readonly property color bgTs: "#80000000"  // translucent fill, 50% black
    readonly property color border: "#5f4c5f"  // focus border, dim label text
    readonly property color foreground: "#e6e6e8"  // default text and icon colour
    readonly property color foregroundTransparent: "#50ffffff"  // dimmed text and icons, 31% white
    readonly property color inactive: "#787c99"  // unselected label colour
    readonly property color red: "#f7768e"  // alert colour, low battery
    readonly property color blue: "#7aa2f7"  // accent, currently unused
    readonly property color yellow: "#e0af68"  // accent, currently unused
    readonly property color green: "#41a6b5"  // accent, currently unused

    // Font
    readonly property int fontSize: 13  // base text size
    readonly property string fontFamily: "JetBrainsMono Nerd Font"  // base family, glyphs come from it

    // -------

    // TaskBar
    readonly property real curveFlare: 28 // Higher -> softer
    readonly property real taskbarFlare: 30  // horizontal length of the bar's flare
    readonly property real pad: 12  // gap between bar content and its flare
    readonly property int barHeight: 30  // bar height
    readonly property int borderThickness: 12  // frame thickness around the screen
    // -------
    // App Launcher
    readonly property int appLauncherRecentsLength: 12  // how many recents are remembered
    readonly property int appLauncherMaxVisible: 7  // rows shown before the list scrolls
    readonly property int appLauncherItemHeight: 42  // height of one app row
    readonly property int appLauncherPanelWidth: 440  // panel width
    readonly property int appLauncherPanelHeight: 88  // height with no rows, search box only
    readonly property real appLauncherFlare: taskbarFlare  // bottom flare length, tracks the bar
    readonly property int appLauncherFlareHeight: 48  // bottom flare vertical radius
    readonly property int appLauncherHeightAnimDuration: 500  // open/close reveal duration, ms
    readonly property real appLauncherHeightAnimType: Easing.OutCubic  // reveal easing
    readonly property int appLauncherRadiusTop: 18  // top corner radius
    readonly property int appLauncherContentMargin: 12  // content inset from the body
    readonly property int appLauncherContentSpacing: 0  // spacing between the stacked parts
    readonly property int appLauncherDragWidth: 36  // drag handle width
    readonly property int appLauncherDragHeight: 4  // drag handle height
    readonly property int appLauncherDragRadius: 2  // drag handle radius
    readonly property int appLauncherContentItemWidth: 1  // spacer, currently unused
    readonly property int appLauncherContentItemHeigth: 8  // spacer, currently unused
    readonly property int appLauncherSearchBoxHeight: 44  // search box height
    readonly property int appLauncherSearchBoxRadius: 10  // search box radius
    readonly property int appLauncherSearchboxFocusBorderWidth: 1  // focus border width
    readonly property real appLauncherSearchBoxFocusOpacity: 0.55  // focus border opacity
    readonly property int appLauncherSearchBoxFocusAnimDuration: 150  // focus fade duration, ms
    readonly property int appLauncherSearchBoxRowMargin: 14  // search text left inset
    readonly property int appLauncherInvContSubsFromWidth: 40  // width kept beside the input
    readonly property string appLauncherSearchBoxText: "Search apps..."  // placeholder text
    readonly property real appLauncherSearchBoxTextOpacity: 0.28  // placeholder opacity
    readonly property int appLauncherSearchBoxTextSize: 13  // search text size, also the empty-state text
    readonly property int applauncherSpaceBtwnSearchAndApps: 8  // gap under the search box
    readonly property string appLauncherNoAppsFound: "No apps found"  // empty-list text
    readonly property real appLauncherNoAppsFoundOpacity: 0.28  // empty-list text opacity
    readonly property int appLauncherAppBgMargin: 2  // selection pill inset top and bottom
    readonly property int appLaucncherAppBgRadius: 10  // selection pill radius
    readonly property int appLauncherAppBgAnimDuration: 100  // selection pill fade, ms
    readonly property int appLauncherIconBubbleMargin: 8  // icon bubble inset left and right
    readonly property int appLauncherIconBubbleSpacing: 12  // gap between bubble and name
    readonly property int appLauncherIconBubbleSize: 36  // icon bubble size
    readonly property int appLauncherIconBubbleRadius: 9  // icon bubble radius
    readonly property int appLauncherIconBubbleAnimDuration: 100  // bubble fade, ms
    readonly property int appLauncherIconImgSize: 22  // icon image size
    readonly property int appLauncherIconImgFallbackTxtSize: 14  // letter shown when the icon is missing
    readonly property color appLauncherIconFallbackColorActive: foreground  // letter colour, selected row
    readonly property color appLauncherIconImgFallbackColorInactive: inactive  // letter colour, idle row
    readonly property int appLauncherIconFallbackAnimDuration: 100  // letter fade, ms
    readonly property int appLauncherAppNamesSpacing: 2  // gap between name and recent pill
    readonly property int appLauncherAppNamesFontSize: 13  // app name size
    readonly property color appLauncherAppNamesColorActive: foreground  // name colour, selected row
    readonly property int appLauncherAppNamesAnimDuration: 100  // name fade, ms
    readonly property int appLauncherRecentlyUsedSpacing: 6  // gap between pill and generic name
    readonly property int appLauncherRecentAppsWidthAddition: 8  // pill padding around its text
    readonly property int appLauncherRecentAppsHeight: 14  // pill height
    readonly property int appLauncherRecentAppsRadius: 4  // pill radius
    readonly property color appLauncherRecentlAppsColor: foreground  // pill fill
    readonly property string appLauncherRecentAppsText: "recent"  // pill label
    readonly property int appLauncherRecentAppsTxtSize: 9  // pill label size
    readonly property color appLauncherRecentAppsTxtColor: border  // pill label colour
    readonly property int appLauncherRecentsGenericTxtSize: 11  // generic-name size
    readonly property real appLauncherRecentsGenericTxtOpacity: 0.38  // generic-name opacity
    readonly property color appLauncherRecentsGenericTxtColor: border  // generic-name colour
    readonly property int appLauncherBottomItemWidth: 1  // bottom padding spacer
    readonly property int appLauncherBottomitemHeight: 4  // bottom padding spacer
    // -------
    // Power Dropdown
    readonly property string powerDropdownIcon: "\uf31f"      // artix logo, the bar trigger
    readonly property int powerDropdownPanelWidth: 200  // panel width
    readonly property int powerDropdownItemHeight: 40  // height of one entry
    readonly property int powerDropdownItemRadius: 10  // entry radius
    readonly property int powerDropdownContentMargin: 8  // content inset, also sets the panel height
    readonly property int powerDropdownMargin: 6       // gap to the frame and the bar
    readonly property int powerDropdownRadius: 14  // panel corner radius
    readonly property int powerDropdownIconBubbleSize: 28  // icon bubble size
    readonly property int powerDropdownIconBubbleRadius: 8  // icon bubble radius
    readonly property int powerDropdownIconSize: 15  // entry icon size
    readonly property int powerDropdownFontSize: 13  // entry label size
    readonly property int powerDropdownAnimDuration: 220  // open/close reveal duration, ms
    readonly property real powerDropdownAnimType: Easing.OutCubic  // reveal easing
    readonly property int menuUnloadGrace: 120       // time a menu outlives its close animation
    // -------
    // Volume Dropdown
    readonly property int volumeDropdownPanelWidth: 340  // panel width
    readonly property int volumeDropdownMargin: powerDropdownMargin  // same gap as the power menu
    readonly property int volumeDropdownRadius: powerDropdownRadius  // panel corner radius
    readonly property int volumeDropdownContentMargin: powerDropdownContentMargin  // content inset
    readonly property int volumeDropdownRowHeight: powerDropdownItemHeight  // height of one row
    readonly property int volumeDropdownRowRadius: powerDropdownItemRadius  // row highlight radius
    readonly property int volumeDropdownIconBubbleSize: powerDropdownIconBubbleSize  // icon bubble size
    readonly property int volumeDropdownIconBubbleRadius: powerDropdownIconBubbleRadius  // icon bubble radius
    readonly property int volumeDropdownIconSize: powerDropdownIconSize  // glyph size
    readonly property int volumeDropdownFontSize: powerDropdownFontSize  // row text size
    readonly property int volumeDropdownAnimDuration: powerDropdownAnimDuration  // reveal duration, ms
    readonly property real volumeDropdownAnimType: powerDropdownAnimType  // reveal easing
    readonly property int volumeDropdownLabelWidth: 62  // label column, after the bubble
    readonly property int volumeDropdownPercentWidth: 40  // percent column, at the right
    readonly property int volumeDropdownStreamSliderWidth: 110  // slider column of a stream row
    readonly property int volumeDropdownSliderHeight: 6  // slider track height
    readonly property int volumeDropdownSliderKnobSize: 12  // slider knob diameter
    readonly property int volumeDropdownDeviceRowHeight: 30  // one entry in a device list
    readonly property int volumeDropdownDeviceIndent: 38  // device list inset, under its bubble
    readonly property int volumeDropdownStreamSpacing: 2  // gap between stream rows
    readonly property int volumeDropdownMaxContentHeight: 420  // taller content scrolls instead
    readonly property real volumeDropdownKeyStep: 0.05  // left/right moves a level by this
    readonly property color volumeDropdownTrackColor: border  // slider track
    readonly property color volumeDropdownFillColor: foreground  // slider fill and knob
    readonly property color volumeDropdownDimColor: inactive  // device names, percent readout
    readonly property string volumeDropdownOutputText: "output"  // output level row label
    readonly property string volumeDropdownInputText: "input"  // input level row label
    readonly property string volumeDropdownStreamsText: "apps"  // per-stream section label
    readonly property string volumeDropdownNoStreamsText: "no streams"  // empty stream list
    readonly property string volumeDropdownOutputIcon: "󰕾"  // speaker, output level
    readonly property string volumeDropdownOutputMutedIcon: "󰝟"  // speaker with a cross, muted
    readonly property string volumeDropdownInputIcon: "󰍬"  // microphone, input level
    readonly property string volumeDropdownInputMutedIcon: "󰍭"  // microphone with a cross, muted
    readonly property string volumeDropdownDeviceIcon: "󰓃"  // speaker box, device rows
    readonly property string volumeDropdownStreamsIcon: "󰎆"  // music note, stream rows
    readonly property string volumeDropdownChevronClosed: "󰅀"  // list closed
    readonly property string volumeDropdownChevronOpen: "󰅃"  // list open
}
