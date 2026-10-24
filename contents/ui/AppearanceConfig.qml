import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kquickcontrols as KQC

KCM.SimpleKCM {
    id: page

    property string cfg_fontFamily
    property int cfg_panelSize
    property alias cfg_hourColorTop: hourTop.color
    property alias cfg_hourColorBottom: hourBottom.color
    property alias cfg_separatorColor: separator.color
    property alias cfg_minuteColorTop: minuteTop.color
    property alias cfg_minuteColorBottom: minuteBottom.color
    property alias cfg_secondsColor: seconds.color
    property alias cfg_dateColor: date.color

    Kirigami.FormLayout {
        QQC2.ComboBox {
            id: fontCombo
            Kirigami.FormData.label: i18n("Font:")
            readonly property var families: Qt.fontFamilies()
            model: [i18n("Metropolis Black (default)"), ...families]
            currentIndex: page.cfg_fontFamily === "" ? 0 : families.indexOf(page.cfg_fontFamily) + 1
            onActivated: page.cfg_fontFamily = currentIndex === 0 ? "" : families[currentIndex - 1]
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Size in the panel:")
            model: [i18n("Compact"), i18n("Medium"), i18n("Large")]
            currentIndex: page.cfg_panelSize
            onActivated: page.cfg_panelSize = currentIndex
        }

        Item { Kirigami.FormData.isSection: true }

        RowLayout {
            Kirigami.FormData.label: i18n("Hours (top, bottom):")
            KQC.ColorButton { id: hourTop; dialogTitle: i18n("Hours, top color") }
            KQC.ColorButton { id: hourBottom; dialogTitle: i18n("Hours, bottom color") }
        }
        KQC.ColorButton {
            id: separator
            Kirigami.FormData.label: i18n("Separator:")
            dialogTitle: i18n("Separator color")
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Minutes (top, bottom):")
            KQC.ColorButton { id: minuteTop; dialogTitle: i18n("Minutes, top color") }
            KQC.ColorButton { id: minuteBottom; dialogTitle: i18n("Minutes, bottom color") }
        }
        KQC.ColorButton {
            id: seconds
            Kirigami.FormData.label: i18n("Seconds:")
            dialogTitle: i18n("Seconds color")
        }
        KQC.ColorButton {
            id: date
            Kirigami.FormData.label: i18n("Date:")
            dialogTitle: i18n("Date color")
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.Button {
            text: i18n("Restore original colors")
            icon.name: "edit-undo"
            onClicked: {
                hourTop.color = page.cfg_hourColorTopDefault;
                hourBottom.color = page.cfg_hourColorBottomDefault;
                separator.color = page.cfg_separatorColorDefault;
                minuteTop.color = page.cfg_minuteColorTopDefault;
                minuteBottom.color = page.cfg_minuteColorBottomDefault;
                seconds.color = page.cfg_secondsColorDefault;
                date.color = page.cfg_dateColorDefault;
            }
        }
    }
}
