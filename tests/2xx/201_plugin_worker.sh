#!/bin/bash

. common.sh

# because of the default-values being set for host, port, uri and protocol,
# plugin_worker will invoke fetch_icinga2_status().
assert_func plugin_worker "${TEST_FAIL}" "Failed to query Icinga2 API"

CSL_USER_PARAMS=( 'ICINGA2_FILE' )
CSL_USER_PARAMS_VALUES['ICINGA2_FILE']='example.dat'
STATE_FILE='example.dat'
assert_func plugin_worker "${TEST_FAIL}" "The state-file.*is not readable or empty"

STATE_FILE='icinga2.state'
#CSL_USER_PARAMS_VALUES['ICINGA2_FILE']='icinga2.state'
assert_func plugin_worker "${TEST_OK}" "${TEST_EMPTY}"
