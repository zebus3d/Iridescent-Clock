import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.workspace.timezoneselector as TimeZones

KCM.SimpleKCM {
    id: page

    property string cfg_timeZone

    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing

        QQC2.CheckBox {
            id: useSystem
            text: i18n("Use the system time zone")
            checked: page.cfg_timeZone === ""
            onToggled: page.cfg_timeZone = checked ? "" : selector.selectedTimeZone
        }

        // Plasma's own map + region/city selector
        TimeZones.TimezoneSelector {
            id: selector
            enabled: !useSystem.checked
            opacity: enabled ? 1 : 0.5
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 22
            Component.onCompleted: selectedTimeZone = page.cfg_timeZone
            onSelectedTimeZoneChanged: {
                if (!useSystem.checked) page.cfg_timeZone = selectedTimeZone;
            }
        }
    }
}
