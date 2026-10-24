/*
    SPDX-FileCopyrightText: zayronxio
    SPDX-License-Identifier: GPL-3.0-or-later
*/
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.workspace.calendar as PlasmaCalendar

PlasmoidItem {
    id: root

    readonly property var cfg: Plasmoid.configuration
    property bool inPanel: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
                           || Plasmoid.formFactor === PlasmaCore.Types.Vertical

    // "Local" is the time engine's source for the system time zone
    readonly property string timeZoneSource: cfg.timeZone || "Local"
    property date now: new Date()

    preferredRepresentation: compactRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    toolTipMainText: timeZoneSource === "Local"
                     ? now.toLocaleDateString(Qt.locale(), Locale.LongFormat)
                     : timeZoneSource.split("/").pop().replace(/_/g, " ")
    toolTipSubText: timeZoneSource === "Local"
                    ? ""
                    : now.toLocaleDateString(Qt.locale(), Locale.LongFormat)

    Plasma5Support.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: [root.timeZoneSource]
        interval: 60000
    }

    // JS dates are always in the system zone: shift by the difference between
    // the chosen zone's UTC offset and ours to get its wall-clock time.
    function currentTime() {
        const date = new Date();
        const data = timeSource.data[timeZoneSource];
        if (timeZoneSource === "Local" || !data || data["Offset"] === undefined)
            return date;
        const localOffset = -date.getTimezoneOffset() * 60;
        return new Date(date.getTime() + (data["Offset"] - localOffset) * 1000);
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = root.currentTime()
    }

    // Metropolis is not monospaced: give each two-digit group the width of the
    // widest digit so the clock (and the panel) doesn't shift every second.
    function maxDigitWidth(fm) {
        let w = 0;
        for (let i = 0; i < 10; i++) w = Math.max(w, fm.advanceWidth(String(i)));
        return w;
    }

    // Text painted with a vertical gradient. The text itself stays hidden and is
    // only used as the gradient's mask, so a new value is redrawn cleanly.
    component GradientText: Item {
        id: gradientText
        property alias text: label.text
        property alias font: label.font
        property color topColor
        property color bottomColor
        implicitHeight: label.implicitHeight

        Text {
            id: label
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            visible: false
        }
        LinearGradient {
            anchors.fill: label
            source: label
            start: Qt.point(0, 0)
            end: Qt.point(0, height)
            gradient: Gradient {
                GradientStop { position: 0.0; color: gradientText.topColor }
                GradientStop { position: 1.0; color: gradientText.bottomColor }
            }
        }
    }

    FontLoader {
        id: metro
        source: "../fonts/Metropolis-Black.ttf"
    }

    // Click on the clock opens the Plasma calendar, with the holidays of the
    // selected day listed below it
    fullRepresentation: ColumnLayout {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 20
        Layout.minimumHeight: Kirigami.Units.gridUnit * 20
        spacing: Kirigami.Units.smallSpacing

        // the holidays plugin reads its regions from Plasma's shared config
        PlasmaCalendar.EventPluginsManager {
            id: eventPlugins
            enabledPlugins: cfg.showHolidays ? ["holidaysevents"] : []
        }

        PlasmaCalendar.MonthView {
            id: calendar
            Layout.fillWidth: true
            Layout.fillHeight: true
            borderOpacity: 0.25
            today: root.now
            eventPluginsManager: eventPlugins
            firstDayOfWeek: cfg.firstDayOfWeek > -1 ? cfg.firstDayOfWeek : Qt.locale().firstDayOfWeek

            property var dayEvents: []
            function updateDayEvents() {
                dayEvents = cfg.showHolidays ? daysModel.eventsForDate(currentDate) : [];
            }
            onCurrentDateChanged: updateDayEvents()

            Connections {
                target: calendar.daysModel
                function onAgendaUpdated(updatedDate) { calendar.updateDayEvents(); }
            }
            Connections {
                target: root
                function onExpandedChanged() {
                    if (root.expanded) calendar.resetToToday();
                }
            }
        }

        Repeater {
            model: calendar.dayEvents
            delegate: RowLayout {
                required property var modelData
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.largeSpacing
                Layout.rightMargin: Kirigami.Units.largeSpacing
                spacing: Kirigami.Units.smallSpacing

                Rectangle {
                    implicitWidth: Kirigami.Units.smallSpacing * 2
                    implicitHeight: implicitWidth
                    radius: width / 2
                    color: modelData.eventColor || Kirigami.Theme.highlightColor
                }
                Text {
                    Layout.fillWidth: true
                    text: modelData.title
                    color: Kirigami.Theme.textColor
                    opacity: modelData.isMinor ? 0.7 : 1
                    elide: Text.ElideRight
                }
            }
        }
    }

    compactRepresentation: Item {
        id: mainContainer

        readonly property bool dateShown: cfg.showDate

        Layout.preferredWidth: inPanel ? timeRow.width + segundos.width + Kirigami.Units.smallSpacing * 2
                                       : Kirigami.Units.gridUnit * 20
        Layout.minimumWidth: inPanel ? Layout.preferredWidth : -1
        Layout.preferredHeight: Kirigami.Units.gridUnit * 10

        FontMetrics { id: bigMetrics; font: hora.font }
        FontMetrics { id: secMetrics; font: segundos.font }
        FontMetrics { id: dateMetrics; font.family: dateText.font.family; font.pixelSize: 100 }
        property real bigDigitW: { bigMetrics.font; return maxDigitWidth(bigMetrics); }
        property real secDigitW: { secMetrics.font; return maxDigitWidth(secMetrics); }

        // In the panel the size comes from the visible glyphs, not the line
        // box, so the digits (and the date) fill the panel height. Every measure is taken at 100 px and scales linearly.
        FontMetrics { id: hourMetrics; font.family: hora.font.family; font.weight: Font.Bold; font.pixelSize: 100 }
        readonly property rect digitBox100: { hourMetrics.font; return hourMetrics.tightBoundingRect("0123456789"); }
        readonly property rect dateBox100: { dateMetrics.font; return dateMetrics.tightBoundingRect(dateText.text); }
        // space left above and below the clock for each size; the large one
        // is negative because it grows into the padding Plasma leaves around
        // the applet
        readonly property real panelMargin: Kirigami.Units.smallSpacing * [1.5, 0.75, -0.5][cfg.panelSize]
        readonly property real dateGap: dateShown ? hora.font.pixelSize * 0.06 : 0
        readonly property real panelPixelSize: {
            hourMetrics.font;
            const rowW100 = 4 * maxDigitWidth(hourMetrics) + hourMetrics.advanceWidth(":");
            const dateK = dateShown ? rowW100 / dateMetrics.advanceWidth(dateText.text) * dateBox100.height / 100 : 0;
            const gapK = dateShown ? 0.06 : 0;
            return 100 * (height - panelMargin * 2) / (digitBox100.height + 100 * (gapK + dateK));
        }
        // distance from the top of a Text item to the top of its glyphs
        function glyphTop(fm, box, pixelSize) { return (fm.ascent + box.y) * pixelSize / 100; }

        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
        }

        // Time display (16:20)
        Item {
            id: timeContainer
            width: mainContainer.width
            height: childrenRect.height
            y: mainContainer.panelMargin - mainContainer.glyphTop(hourMetrics, mainContainer.digitBox100,
                                                                  hora.font.pixelSize)
            anchors.centerIn: inPanel ? undefined : parent

            Row {
                id: timeRow
                spacing: 0
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: -segundos.width / 2

                // Hours with blue gradient
                GradientText {
                    id: hora
                    text: {
                        if (!cfg.hourFormat) return Qt.formatDateTime(root.now, "HH");
                        const h = root.now.getHours() % 12;
                        return String(h === 0 ? 12 : h);
                    }
                    width: mainContainer.bigDigitW * 2
                    font.pixelSize: inPanel ? mainContainer.panelPixelSize
                                            : Math.min(mainContainer.width, mainContainer.height) * 0.36
                    font.family: cfg.fontFamily || metro.name
                    font.weight: Font.Bold
                    topColor: cfg.hourColorTop
                    bottomColor: cfg.hourColorBottom
                }

                // Colon separator
                Text {
                    text: ":"
                    font.pixelSize: hora.font.pixelSize
                    font.family: hora.font.family
                    font.weight: Font.Bold
                    color: cfg.separatorColor
                }

                // Minutes with orange-pink gradient
                GradientText {
                    id: minutos
                    text: Qt.formatDateTime(root.now, "mm")
                    width: mainContainer.bigDigitW * 2
                    font.pixelSize: hora.font.pixelSize
                    font.family: hora.font.family
                    font.weight: Font.Bold
                    topColor: cfg.minuteColorTop
                    bottomColor: cfg.minuteColorBottom
                }
            }

            // Seconds as superscript
            Text {
                id: segundos
                visible: cfg.showSeconds
                text: Qt.formatDateTime(root.now, "ss")
                width: visible ? mainContainer.secDigitW * 2 : 0
                font.pixelSize: hora.font.pixelSize * 0.4
                font.family: hora.font.family
                font.weight: Font.Bold
                color: cfg.secondsColor
                anchors.left: timeRow.right
                anchors.top: timeRow.top
                // in the panel, line its digits up with the top of the hour
                anchors.topMargin: inPanel ? mainContainer.glyphTop(hourMetrics, mainContainer.digitBox100,
                                                                    hora.font.pixelSize * 0.6)
                                           : -5
            }
        }

        // Date display centered below time
        Text {
            id: dateText
            visible: mainContainer.dateShown
            width: mainContainer.width
            horizontalAlignment: Text.AlignHCenter
            // Qt.formatDate() would use English day/month names
            text: root.now.toLocaleDateString(Qt.locale(), cfg.dateFormat)
            // in the panel, scale it so it spans the same width as the hour
            font.pixelSize: inPanel ? 100 * timeRow.width / dateMetrics.advanceWidth(text)
                                    : Math.min(mainContainer.width, mainContainer.height) * 0.08
            font.family: hora.font.family
            color: cfg.dateColor
            anchors.horizontalCenter: timeContainer.horizontalCenter
            anchors.horizontalCenterOffset: -segundos.width / 2
            y: mainContainer.panelMargin + mainContainer.digitBox100.height * hora.font.pixelSize / 100
               + mainContainer.dateGap - mainContainer.glyphTop(dateMetrics, mainContainer.dateBox100, font.pixelSize)
            anchors.top: inPanel ? undefined : timeContainer.bottom
            anchors.topMargin: 2
        }
    }
}
