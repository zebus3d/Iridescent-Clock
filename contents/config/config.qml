import QtQuick
import org.kde.plasma.configuration
import org.kde.plasma.plasmoid

ConfigModel {
	ConfigCategory {
		name: i18n("General")
		icon: "preferences-desktop-clock"
		source: "GeneralConfig.qml"
	}
	ConfigCategory {
		name: i18n("Appearance")
		icon: "preferences-desktop-color"
		source: "AppearanceConfig.qml"
	}
	ConfigCategory {
		name: i18n("Time Zone")
		icon: "preferences-system-time"
		source: "TimeZoneConfig.qml"
	}
	ConfigCategory {
		name: i18n("Holidays")
		icon: "view-calendar-holiday"
		source: "HolidaysConfig.qml"
		visible: Plasmoid.configuration.showHolidays
	}
}
