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
    property int cfg_firstDayOfWeek
    property alias cfg_showHolidays: showHolidays.checked

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
            model: page.dateFormats.map(f => new Date().toLocaleDateString(Qt.locale(), f))
            currentIndex: Math.max(0, page.dateFormats.indexOf(page.cfg_dateFormat))
            onActivated: page.cfg_dateFormat = page.dateFormats[currentIndex]
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("First day of week:")
            // index 0 follows the system locale, then Sunday (0) ... Saturday (6)
            model: [i18n("Use region defaults")].concat([0, 1, 2, 3, 4, 5, 6].map(d => {
                const name = Qt.locale().standaloneDayName(d, Locale.LongFormat);
                return name.charAt(0).toUpperCase() + name.slice(1);
            }))
            currentIndex: page.cfg_firstDayOfWeek + 1
            onActivated: page.cfg_firstDayOfWeek = currentIndex - 1
        }

        QQC2.CheckBox {
            id: showHolidays
            text: i18n("Show holidays in the calendar")
        }
    }
}
