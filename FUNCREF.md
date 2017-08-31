# check_icinga2

| Tag | Value |
| - | - |
| Author | Andreas Unterkircher |
| Version | 1.0 |
| License | AGPLv3 |

## 1. Function `plugin_params_validate`

This functions validates the provided command-line parameters and returns 0,
if the given arguments are valid. otherwise it returns 1.

### 1b. Returns

Type: `int`

## 2. Function `plugin_worker`

This function gets kicked by the monitoring-common-shell-library as entry
point to this plugin. If a state-file has been provided (--file), that one
is used as input information. Otherwise it calls fetch_icinga2_status()
to retrieve a fresh status information. Afterwards it parses and evalautes
the retrieved informations.

### 2b. Returns

Type: `int`

## 3. Function `fetch_icinga2_status`

This function retrieves the Icinga2 state informations and counters via
the Icinga2 API. It utilizes 'curl' to access the API via HTTP or HTTPS. On
success, it returns 0, otherwise 1.

### 3b. Returns

Type: `int`

## 4. Function `parse_icinga2_status`

This function parses the $STATE_FILE (either a locally stored one, or
a fresh, retrieved from the Icinga2 API. The parsed information gets
stored into the $RESULT associative array and will later be handled by
eval_icinga2_status(). On success, it returns 0. Otherwise it will return 1.

### 4b. Returns

Type: `1`

## 5. Function `eval_icinga2_status`

This function evaluates the parsed heath-information that has been previously
stored in $RESULTS. TODO At the moment, that is actually not matching against
thresholds. Just OK if state-information exists, otherwise it issues a WARNING.

### 5b. Returns

Type: `int`

## 6. Function `plugin_startup`

This function gets invoked by the monitoring-common-shell-library. In our case,
it requests a temporary directory from the library and installs a cleanup
trap, that tries to ensure, that any residues in the filesystem get removed.

### 6b. Returns

Type: `int`

[^1]: Created by shell-docs-gen.sh v1.3.1 on Don Aug 31 07:08:40 CEST 2017.
