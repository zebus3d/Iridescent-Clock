import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: page

    property bool cfg_hourFormat
    property alias cfg_showSeconds: showSeconds.checked
    property alias cfg_showDate: showDate.checked
    property string cfg_dateFormat

    readonly property var dateFormats: ["dd/MM/yy", "dd/MM/yyyy", "yyyy-MM-dd", "d MMM", "ddd d", "MMM, dddd d"]

    Kirigami.FormLayout {
        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Time format:")
            model: [i18n("24 hour"), i18n("12 hour")]
            currentIndex: page.cfg_hourFormat ? 1 : 0
            onActivated: page.cfg_hourFormat = currentIndex === 1
        }

        QQC2.CheckBox {
            id: showSeconds
            text: i18n("Show seconds")
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.CheckBox {
            id: showDate
            Kirigami.FormData.label: i18n("Date:")
            text: i18n("Show date")
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Date format:")
            enabled: showDate.checked
            // show each format applied to today's date
            model: page.dateFormats.map(f => Qt.formatDate(new Date(), f))
            currentIndex: Math.max(0, page.dateFormats.indexOf(page.cfg_dateFormat))
            onActivated: page.cfg_dateFormat = page.dateFormats[currentIndex]
        }
    }
}
