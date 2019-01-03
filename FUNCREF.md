# check_icinga2

| Tag | Value |
| - | - |
| Author | Andreas Unterkircher |
| Version | 1.2 |
| License | AGPLv3 |

<!-- if a table-of-contents gets actually rendered, depends on your markdown-viewer -->
[TOC]

## 1. Variable `PROGNAME`

### 1a. About

Plugin Program Name

## 2. Variable `VERSION`

### 2a. About

Plugin Version

## 3. Function `plugin_params_validate`

### 3a. About

This functions validates the provided command-line parameters and returns 0,
if the given arguments are valid. otherwise it returns 1.

### 3b. Return-Code Example

| Desc | Value |
| - | - |
| Type | `int` |

## 4. Function `plugin_worker`

### 4a. About

This function gets kicked by the monitoring-common-shell-library as entry
point to this plugin. If a state-file has been provided (--file), that one
is used as input information. Otherwise it calls fetch_icinga2_status()
to retrieve a fresh status information. Afterwards it parses and evalautes
the retrieved informations.

### 4b. Return-Code Example

| Desc | Value |
| - | - |
| Type | `int` |

## 5. Function `fetch_icinga2_status`

### 5a. About

This function retrieves the Icinga2 state informations and counters via
the Icinga2 API. It utilizes 'curl' to access the API via HTTP or HTTPS. On
success, it returns 0, otherwise 1.

### 5b. Return-Code Example

| Desc | Value |
| - | - |
| Type | `int` |

## 6. Function `parse_icinga2_status`

### 6a. About

This function parses the $STATE_FILE (either a locally stored one, or
a fresh, retrieved from the Icinga2 API. The parsed information gets
stored into the $RESULT associative array and will later be handled by
eval_icinga2_status(). On success, it returns 0. Otherwise it will return 1.

### 6b. Return-Code Example

| Desc | Value |
| - | - |
| Type | `1` |

## 7. Function `eval_icinga2_status`

### 7a. About

This function evaluates the parsed heath-information that has been previously
stored in $RESULTS. TODO At the moment, that is actually not matching against
thresholds. Just OK if state-information exists, otherwise it issues a WARNING.

### 7b. Return-Code Example

| Desc | Value |
| - | - |
| Type | `int` |

## 8. Function `plugin_startup`

### 8a. About

This function gets invoked by the monitoring-common-shell-library. In our case,
it requests a temporary directory from the library and installs a cleanup
trap, that tries to ensure, that any residues in the filesystem get removed.

### 8b. Return-Code Example

| Desc | Value |
| - | - |
| Type | `int` |

[^1]: Created by _shell-docs-gen.sh_ _v1.6.1_ on Thu Jan  3 20:23:25 UTC 2019.
