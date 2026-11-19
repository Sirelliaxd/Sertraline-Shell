pragma Singleton

import Quickshell
import QtQuick

Singleton {
    // Colors

    readonly property bool backgroundTransparency: true
    // -------
    readonly property color background: backgroundTransparency ? bgTs : bg
    readonly property color bg: "#14141c"
    readonly property color bgTs: "#80000000"
    readonly property color border: "#5f4c5f"
    readonly property color foreground: "#e6e6e8"
    readonly property color foregroundTransparent: "#50ffffff"
    readonly property color inactive: "#787c99"
    readonly property color red: "#f7768e"
    readonly property color blue: "#7aa2f7"
    readonly property color yellow: "#e0af68"
    readonly property color green: "#41a6b5"

    // Font
    readonly property int fontSize: 13
    readonly property string fontFamily: "JetBrainsMono Nerd Font"

    // -------

    // TaskBar
    readonly property real curveFlare: 28 // Higher -> softer
    readonly property real taskbarFlare: 30
    readonly property real pad: 12
    readonly property int barHeight: 30
    readonly property int borderThickness: 12
    // -------
    // App Launcher
    readonly property int appLauncherRecentsLength: 12
    readonly property int appLauncherMaxVisible: 7
    readonly property int appLauncherItemHeight: 42
    readonly property int appLauncherPanelWidth: 440
    readonly property int appLauncherPanelHeight: 88
    readonly property int appLauncherHeigthAppCountChangeAnimDuration: 500
    readonly property real appLauncherHeigthAppCountChangeAnimType: Easing.OutCubic
    readonly property int appLauncherRadiusTop: 18
    readonly property int appLauncherRadiusBottom: 0
    readonly property int appLauncherBorderWidth: 1
    readonly property int appLauncherSlideAnimDuration: 500
    readonly property real appLauncherSlideAnimType: Easing.OutCubic
    readonly property int appLauncherContentMargin: 12
    readonly property int appLauncherContentSpacing: 0
    readonly property int appLauncherDragWidth: 36
    readonly property int appLauncherDragHeight: 4
    readonly property int appLauncherDragRadius: 2
    readonly property int appLauncherContentItemWidth: 1
    readonly property int appLauncherContentItemHeigth: 8
    readonly property int appLauncherSearchBoxHeight: 44
    readonly property int appLauncherSearchBoxRadius: 10
    readonly property int appLauncherSearchboxFocusBorderWidth: 1
    readonly property real appLauncherSearchBoxFocusOpacity: 0.55
    readonly property int appLauncherSearchBoxFocusAnimDuration: 150
    readonly property int appLauncherSearchBoxRowMargin: 14
    readonly property int appLauncherSearchBoxRowSpacing: 10
    readonly property int appLauncherInvContSubsFromWidth: 40
    readonly property string appLauncherSearchBoxText: "Search apps..."
    readonly property real appLauncherSearchBoxTextOpacity: 0.28
    readonly property int appLauncherSearchBoxTextSize: 13
    readonly property int applauncherSpaceBtwnSearchAndApps: 8
    readonly property string appLauncherNoAppsFound: "No apps found"
    readonly property real appLauncherNoAppsFoundOpacity: 0.28
    readonly property int appLauncherAppBgMargin: 2
    readonly property int appLaucncherAppBgRadius: 10
    readonly property int appLauncherAppBgAnimDuration: 100
    readonly property int appLauncherIconBubbleMargin: 8
    readonly property int appLauncherIconBubbleSpacing: 12
    readonly property int appLauncherIconBubbleSize: 36
    readonly property int appLauncherIconBubbleRadius: 9
    readonly property int appLauncherIconBubbleAnimDuration: 100
    readonly property int appLauncherIconImgSize: 22
    readonly property color appLauncherIconFallbackColorActive: foreground
    readonly property color appLauncherIconFallbackColoraInctive: inactive
    readonly property int appLauncherIconFallbackAnimDuration: 100
    readonly property int appLauncherAppNamesSpacing: 2
    readonly property int appLauncherAppNamesFontSize: 13
    readonly property color appLauncherAppNamesColorActive: foreground
    readonly property int appLauncherAppNamesAnimDuration: 100
    readonly property int appLauncherRecentlyUsedSpacing: 6
    readonly property int appLauncherRecentAppsWidthAddition: 8
    readonly property int appLauncherRecentAppsHeight: 14
    readonly property int appLauncherRecentAppsRadius: 4
    readonly property color appLauncherRecentlAppsColor: foreground
    readonly property string appLauncherRecentAppsText: "recent"
    readonly property int appLauncherRecentAppsTxtSize: 9
    readonly property color appLauncherRecentAppsTxtColor: border
    readonly property int appLauncherRecentsGenericTxtSize: 11
    readonly property real appLauncherRecentsGenericTxtOpacity: 0.38
    readonly property color appLauncherRecentsGenericTxtColor: border
    readonly property int appLauncherBottomItemWidth: 1
    readonly property int appLauncherBottomitemHeight: 4
}
