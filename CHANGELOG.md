# Changes in check\_icinga2

## 1.1.1 (unreleased)

* require mcsl >= v1.6.4
* before calling has\_param\_value(), first has\_param() has to
  be called, to check for a command-line parameter to actually exist.

## 1.1 (2017-08-31)

* update code to make shellcheck happy.
* remove some functions that are now already provided by the
  monitoring-common-shell-library
* fix a bug in the if-conditions on verify x509 cert & key params.

## 1.0 (2017-08-19)

* Initial release
* No further threshold evaluation rather than returning OK if the
  Icinga2 statistics were successfully retrieved via the Icinga2 API
* Output a lot of performance-data
