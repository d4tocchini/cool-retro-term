/*******************************************************************************
* Copyright (c) 2013 "Filippo Scognamiglio"
* https://github.com/Swordfish90/cool-retro-term
*
* This file is part of cool-retro-term.
*
* cool-retro-term is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*******************************************************************************/

import QtQuick 2.2
import QtQuick.Controls 1.1

import QMLTermWidget 1.0

import "utils.js" as Utils

Item{
    id: terminalContainer

    property size virtualResolution: Qt.size(kterminal.width, kterminal.height)
    property alias mainTerminal: kterminal

    property ShaderEffectSource mainSource: kterminalSource
    property BurnInEffect burnInEffect: burnInEffect
    property real fontWidth: 1.0
    property real screenScaling: 1.0
    property real scaleTexture: 1.0
    property alias title: ksession.title
    property alias kterminal: kterminal

    anchors.leftMargin: frame.displacementLeft * appSettings.windowScaling
    anchors.rightMargin: frame.displacementRight * appSettings.windowScaling
    anchors.topMargin: frame.displacementTop * appSettings.windowScaling
    anchors.bottomMargin: frame.displacementBottom * appSettings.windowScaling

    property size terminalSize: kterminal.terminalSize
    property size fontMetrics: kterminal.fontMetrics

    // Manage copy and paste
    Connections{
        target: copyAction
        onTriggered: kterminal.copyClipboard();
    }
    Connections{
        target: pasteAction
        onTriggered: kterminal.pasteClipboard()
    }

    //When settings are updated sources need to be redrawn.
    Connections{
        target: appSettings
        onFontScalingChanged: terminalContainer.updateSources();
        onFontWidthChanged: terminalContainer.updateSources();
    }
    Connections{
        target: terminalContainer
        onWidthChanged: terminalContainer.updateSources();
        onHeightChanged: terminalContainer.updateSources();
    }
    function updateSources() {
        kterminal.update();
    }

    QMLTermWidget {
        id: kterminal
        width: Math.floor(parent.width / (screenScaling * fontWidth))
        height: Math.floor(parent.height / screenScaling)

        colorScheme: "cool-retro-term"

        smooth: !appSettings.lowResolutionFont
        enableBold: false
        fullCursorHeight: true

        session: QMLTermSession {
            id: ksession

            onFinished: {
                Qt.quit()
            }
        }

        QMLTermScrollbar {
            id: kterminalScrollbar
            terminal: kterminal
            anchors.margins: width * 0.5
            width: terminal.fontMetrics.width * 0.75
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 1
                anchors.bottomMargin: 1
                color: "white"
                radius: width * 0.25
                opacity: 0.7
            }
        }

        function handleFontChanged(fontFamily, pixelSize, lineSpacing, screenScaling, fontWidth) {
            kterminal.antialiasText = !appSettings.lowResolutionFont;
            font.pixelSize = pixelSize;
            font.family = fontFamily;

            terminalContainer.fontWidth = fontWidth;
            terminalContainer.screenScaling = screenScaling;
            scaleTexture = Math.max(1.0, Math.floor(screenScaling * appSettings.windowScaling));

            kterminal.lineSpacing = lineSpacing;
        }

        function startSession() {
            appSettings.initializedSettings.disconnect(startSession);

            // Retrieve the variable set in main.cpp if arguments are passed.
            if (defaultCmd) {
                ksession.setShellProgram(defaultCmd);
                ksession.setArgs(defaultCmdArgs);
            } else if (appSettings.useCustomCommand) {
                var args = Utils.tokenizeCommandLine(appSettings.customCommand);
                ksession.setShellProgram(args[0]);
                ksession.setArgs(args.slice(1));
            } else if (!defaultCmd && Qt.platform.os === "osx") {
                // OSX Requires the following default parameters for auto login.
                ksession.setArgs(["-i", "-l"]);
            }

            if (workdir)
                ksession.initialWorkingDirectory = workdir;

            ksession.startShellProgram();
            forceActiveFocus();
        }
        Component.onCompleted: {
            appSettings.terminalFontChanged.connect(handleFontChanged);
            appSettings.initializedSettings.connect(startSession);
        }
    }
    Component {
        id: linuxContextMenu
        Menu{
            id: contextmenu
            MenuItem { action: copyAction }
            MenuItem { action: pasteAction }
            MenuSeparator { visible: !appSettings.showMenubar }
            MenuItem { action: showsettingsAction ; visible: !appSettings.showMenubar}
            MenuSeparator { visible: !appSettings.showMenubar }
            CRTMainMenuBar { visible: !appSettings.showMenubar }
        }
    }
    Component {
        id: osxContextMenu
        Menu{
            id: contextmenu
            MenuItem{action: copyAction}
            MenuItem{action: pasteAction}
        }
    }
    Loader {
        id: menuLoader
        sourceComponent: (Qt.platform.os === "osx" ? osxContextMenu : linuxContextMenu)
    }
    property alias contextmenu: menuLoader.item

    MouseArea{
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        anchors.fill: parent
        cursorShape: kterminal.terminalUsesMouse ? Qt.ArrowCursor : Qt.IBeamCursor
        onWheel:{
            if(wheel.modifiers & Qt.ControlModifier){
               wheel.angleDelta.y > 0 ? zoomIn.trigger() : zoomOut.trigger();
            } else {
                var coord = correctDistortion(wheel.x, wheel.y);
                kterminal.simulateWheel(coord.x, coord.y, wheel.buttons, wheel.modifiers, wheel.angleDelta);
            }
        }
        onDoubleClicked: {
            var coord = correctDistortion(mouse.x, mouse.y);
            kterminal.simulateMouseDoubleClick(coord.x, coord.y, mouse.button, mouse.buttons, mouse.modifiers);
        }
        onPressed: {
            if((!kterminal.terminalUsesMouse || mouse.modifiers & Qt.ShiftModifier) && mouse.button == Qt.RightButton) {
                contextmenu.popup();
            } else {
                var coord = correctDistortion(mouse.x, mouse.y);
                kterminal.simulateMousePress(coord.x, coord.y, mouse.button, mouse.buttons, mouse.modifiers)
            }
        }
        onReleased: {
            var coord = correctDistortion(mouse.x, mouse.y);
            kterminal.simulateMouseRelease(coord.x, coord.y, mouse.button, mouse.buttons, mouse.modifiers);
        }
        onPositionChanged: {
            var coord = correctDistortion(mouse.x, mouse.y);
            kterminal.simulateMouseMove(coord.x, coord.y, mouse.button, mouse.buttons, mouse.modifiers);
        }

        function correctDistortion(x, y){
            x = x / width;
            y = y / height;

            var cc = Qt.size(0.5 - x, 0.5 - y);
            var distortion = (cc.height * cc.height + cc.width * cc.width) * appSettings.screenCurvature * appSettings.screenCurvatureSize;

            return Qt.point((x - cc.width  * (1+distortion) * distortion) * kterminal.width,
                           (y - cc.height * (1+distortion) * distortion) * kterminal.height)
        }
    }
    ShaderEffectSource{
        id: kterminalSource
        sourceItem: kterminal
        hideSource: true
        wrapMode: ShaderEffectSource.ClampToEdge
        visible: false
        textureSize: Qt.size(kterminal.width * scaleTexture, kterminal.height * scaleTexture);
    }

    BurnInEffect {
        id: burnInEffect
    }
}
