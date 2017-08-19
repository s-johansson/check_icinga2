This is check_icinga2.

This plugin checks the icinga2 state via its API.

While a monitoring system that tries to verify its own health-state
a bit violates some fundamental monitoring concepts, it might be
still useful as pre-indicator on reaching certain thresholds.
Also the plugin provides the retrieved status-information as
performance-data back to Icinga2. So you could easily graph them
in the same manner as you do with other plugin performance-datas.

Basically the plugin relys on the monitoring-common-shell-library and requires
Bash (4.0).

See LICENSE file for licensing information.

(c) 2017 Andreas Unterkircher <unki@netshadow.net>.
