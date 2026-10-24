/*
    SPDX-FileCopyrightText: zayronxio
    SPDX-License-Identifier: GPL-3.0-or-later
*/
import QtQuick 2.12
import QtQuick.Layouts 1.12
import Qt5Compat.GraphicalEffects
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.workspace.calendar as PlasmaCalendar

PlasmoidItem {
    id: root

    property string codeleng: ((Qt.locale().name)[0]+(Qt.locale().name)[1])
    property bool formato12Hour: plasmoid.configuration.hourFormat
    property bool visibleTxt: Plasmoid.configuration.activeText
    property bool inPanel: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
                           || Plasmoid.formFactor === PlasmaCore.Types.Vertical

    preferredRepresentation: compactRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    function desktoptext(languageCode) {
        const translations = {
            "es": "son las",         // Spanish
            "en": "it is",           // English
            "hi": "यह",              // Hindi
            "fr": "il est",          // French
            "de": "es ist",          // German
            "it": "sono le",         // Italian
            "pt": "são",             // Portuguese
            "ru": "сейчас",          // Russian
            "zh": "现在是",           // Chinese (Mandarin)
            "ja": "今",              // Japanese
            "ko": "지금은",           // Korean
            "nl": "het is"           // Dutch
        };

        // Return the translation for the language code or default to English if not found
        return translations[languageCode] || translations["en"];
    }

    // Metropolis is not monospaced: give each two-digit group the width of the
    // widest digit so the clock (and the panel) doesn't shift every second.
    function maxDigitWidth(fm) {
        let w = 0;
        for (let i = 0; i < 10; i++) w = Math.max(w, fm.advanceWidth(String(i)));
        return w;
    }

    FontLoader {
        id: milk
        source: "../fonts/Milkshake.ttf"
    }
    FontLoader {
        id: metro
        source: "../fonts/Metropolis-Black.ttf"
    }

    // Click on the clock opens the Plasma calendar
    fullRepresentation: PlasmaCalendar.MonthView {
        id: calendar
        Layout.minimumWidth: Kirigami.Units.gridUnit * 20
        Layout.minimumHeight: Kirigami.Units.gridUnit * 20
        borderOpacity: 0.25
        today: new Date()

        Connections {
            target: root
            function onExpandedChanged() {
                if (root.expanded) {
                    calendar.today = new Date();
                    calendar.resetToToday();
                }
            }
        }
    }

    compactRepresentation: Item {
        id: mainContainer
        Layout.preferredWidth: inPanel ? timeRow.width + segundos.width + Kirigami.Units.smallSpacing * 2
                                       : Kirigami.Units.gridUnit * 20
        Layout.minimumWidth: inPanel ? Layout.preferredWidth : -1
        Layout.preferredHeight: Kirigami.Units.gridUnit * 10

        FontMetrics { id: bigMetrics; font: hora.font }
        FontMetrics { id: secMetrics; font: segundos.font }
        FontMetrics { id: dateMetrics; font.family: dateText.font.family; font.pixelSize: 100 }
        property real bigDigitW: { bigMetrics.font; return maxDigitWidth(bigMetrics); }
        property real secDigitW: { secMetrics.font; return maxDigitWidth(secMetrics); }
        
        // Time display (16:20)
        Item {
            id: timeContainer
            width: mainContainer.width
            height: childrenRect.height
            anchors.centerIn: parent
            anchors.verticalCenterOffset: inPanel ? -(dateText.height + dateText.anchors.topMargin) / 2 : 0
            
            Row {
                id: timeRow
                spacing: 0
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: -segundos.width / 2
                anchors.left: undefined
                anchors.right: undefined
                
                // Hours with blue gradient
                Text {
                    id: hora
                    property var currentDate: new Date()
                    text: formato12Hour
                    ? (currentDate.getHours() === 0
                    ? "12"
                    : (currentDate.getHours() <= 12
                    ? String(currentDate.getHours())
                    : String(currentDate.getHours() - 12)))
                    : Qt.formatDateTime(currentDate, "HH")
                    width: mainContainer.bigDigitW * 2
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: inPanel ? mainContainer.height * 0.5
                                             : Math.min(mainContainer.width, mainContainer.height) * 0.36
                    font.family: metro.name
                    font.weight: Font.Bold
                    
                    LinearGradient {
                        anchors.fill: parent
                        source: parent
                        start: Qt.point(0, 0)
                        end: Qt.point(0, parent.height)
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#78C3FB" }  // Light blue
                            GradientStop { position: 1.0; color: "#3A66F9" }  // Darker blue
                        }
                    }
                }
                
                // Colon separator
                Text {
                    text: ":"
                    font.pixelSize: hora.font.pixelSize
                    font.family: hora.font.family
                    font.weight: Font.Bold
                    color: "#DDDDDD"
                }
                
                // Minutes with orange-pink gradient
                Text {
                    id: minutos
                    property var currentDate: hora.currentDate
                    text: Qt.formatDateTime(currentDate, "mm")
                    width: mainContainer.bigDigitW * 2
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: hora.font.pixelSize
                    font.family: hora.font.family
                    font.weight: Font.Bold
                    
                    LinearGradient {
                        anchors.fill: parent
                        source: parent
                        start: Qt.point(0, 0)
                        end: Qt.point(0, parent.height)
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#F9A55A" }  // Orange
                            GradientStop { position: 1.0; color: "#F25576" }  // Pink
                        }
                    }
                }
            }
            
            // Seconds as superscript
            Text {
                id: segundos
                property var currentDate: hora.currentDate
                text: Qt.formatDateTime(currentDate, "ss")
                width: mainContainer.secDigitW * 2
                font.pixelSize: hora.font.pixelSize * 0.4
                font.family: hora.font.family
                font.weight: Font.Bold
                color: "#4DD8C8"  // Teal
                anchors.left: timeRow.right
                anchors.top: timeRow.top
                anchors.topMargin: inPanel ? 0 : -5
            }
        }
        
        // Date display centered below time
        Text {
            id: dateText
            width: mainContainer.width
            horizontalAlignment: Text.AlignHCenter
            property var currentDate: hora.currentDate
            text: Qt.formatDateTime(currentDate, inPanel ? "dd/MM/yy" : "MMM, dddd d")
            // in the panel, scale it so it spans the same width as the hour
            font.pixelSize: inPanel ? 100 * timeRow.width / dateMetrics.advanceWidth(text)
                                    : Math.min(mainContainer.width, mainContainer.height) * 0.08
            font.family: hora.font.family
            color: "#CC73E1"  // Light purple
            anchors.horizontalCenter: timeContainer.horizontalCenter
            anchors.horizontalCenterOffset: -segundos.width / 2
            anchors.top: timeContainer.bottom
            anchors.topMargin: inPanel ? -hora.font.pixelSize * 0.08 : 2
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                hora.currentDate = new Date()
                minutos.currentDate = hora.currentDate
                segundos.currentDate = hora.currentDate
                dateText.currentDate = hora.currentDate
            }
        }
    }
}