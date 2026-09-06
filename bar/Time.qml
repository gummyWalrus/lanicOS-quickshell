pragma Singleton

import Quickshell
import QtQuick

Singleton {

  readonly property string time: {
    Qt.formatDateTime(clock.date, "hh:mm")
    // The below format string matches the default output of the 'date' command
    // Qt.formatDateTime(clock.date, "ddd MMM d hh:mm:ss AP t yyyy")
  }

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }
}