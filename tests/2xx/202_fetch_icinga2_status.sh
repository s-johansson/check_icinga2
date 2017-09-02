#!/bin/bash

. common.sh

# because of the default-values being set for host, port, uri and protocol,
# plugin_worker will invoke fetch_icinga2_status().
assert_func fetch_icinga2_status "${TEST_FAIL}" "Failed to query Icinga2 API"

CSL_USER_PARAMS=()
CSL_USER_PARAMS_VALUES=()
CSL_USER_PARAMS_DEFAULT_VALUES=()

CSL_USER_PARAMS+=( 'ICINGA2_HOST' )
CSL_USER_PARAMS_VALUES['ICINGA2_HOST']='localhost'
assert_func fetch_icinga2_status "${TEST_FAIL}" "Not all required parameters are set"
CSL_USER_PARAMS+=( 'ICINGA2_PORT' )
CSL_USER_PARAMS_VALUES['ICINGA2_PORT']='8080'
assert_func fetch_icinga2_status "${TEST_FAIL}" "Not all required parameters are set"
CSL_USER_PARAMS+=( 'ICINGA2_URI' )
CSL_USER_PARAMS_VALUES['ICINGA2_URI']='/status'
assert_func fetch_icinga2_status "${TEST_FAIL}" "Not all required parameters are set"
CSL_USER_PARAMS+=( 'ICINGA2_PROTO' )
CSL_USER_PARAMS_VALUES['ICINGA2_PROTO']='https'
assert_func fetch_icinga2_status "${TEST_FAIL}" "Failed to query Icinga2 API"

unset -v CSL_USER_PARAMS CSL_USER_PARAMS_VALUES CSL_USER_PARAMS_DEFAULT_VALUES
