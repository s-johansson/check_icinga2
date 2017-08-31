This is check_icinga2 v1.1.

This plugin checks the Icinga2 state via the Icinga2 API.

While a monitoring system that tries to verify its own health-state
a kind of violate fundamental monitoring principals, it might be still
considered useful as pre-indicator on reaching certain thresholds like
check-latency etc.

Also the plugin provides the retrieved status-information as
performance-data back to Icinga2. So you could easily graph them
in the same manner as you do with other plugin performance-datas.

For this, you can find an example Grafana dashboard in the grafana/
sub-directory.

Basically this plugin relys on the monitoring-common-shell-library and
requires Bash (4.0). Furthermore it needs the JSON-parser 'jq'.

See LICENSE file for licensing information.

(c) 2017 Andreas Unterkircher <unki@netshadow.net>.
