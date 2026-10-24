# Iridescent Clock

A colorful digital clock widget (plasmoid) for **KDE Plasma 6**. It shows the time
with a blue gradient for the hours and an orange-pink gradient for the minutes, small
seconds as a superscript and the date below. It works in a panel and on the desktop,
and clicking it opens the Plasma calendar.

## Features

- Fits the panel: no background frame, and the date is scaled to the width of the
  hour.
- Steady width: the digits don't shift the widget every second.
- Click to open the Plasma calendar.
- **General** settings: 24 or 12 hour time, show or hide seconds, show or hide the
  date, date format.
- **Appearance** settings: font and the color of each part (hours, separator, minutes,
  seconds, date), with a button to restore the original colors.
- **Time Zone** settings: the system time zone or any other, chosen on Plasma's map
  or by region and city. The tooltip shows the city.

## Installation

Requires Plasma 6.

```bash
git clone https://github.com/zebus3d/Iridescent-Clock.git
kpackagetool6 -t Plasma/Applet -i Iridescent-Clock
```

Then right-click the panel or desktop, choose *Add or Manage Widgets* and look for
**Iridescent**.

To update an installed copy, run `kpackagetool6 -t Plasma/Applet -u Iridescent-Clock`
and restart Plasma (`kquitapp6 plasmashell && kstart plasmashell`).

## Credits

This is a fork, modified by [zebus3d](https://github.com/zebus3d), of the original
widget by its authors:

- **Dharam Dhurandhar** ([ddh4r4m/epoch](https://github.com/ddh4r4m/epoch)),
  [Iridescent on the KDE Store](https://store.kde.org/p/2136299/).
- **zayronxio**, author of the code it builds on.

Changes in this fork: Plasma 6 packaging fix, panel layout, calendar popup, and
settings for time format, date, font, colors and time zone.

Bundled font: Metropolis by Chris Simpson.

## License

GPL-3.0-or-later.
