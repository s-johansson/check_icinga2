#!/bin/bash

. common.sh

CSL_USER_PARAMS=()
CSL_USER_PARAMS_VALUES=()
CSL_USER_DEFAULT_VALUES=()
assert_func plugin_params_validate "${TEST_OK}" "${TEST_EMPTY}"

CSL_USER_PARAMS+=( 'ICINGA2_FILE' )
CSL_USER_PARAMS_VALUES['ICINGA2_FILE']='aaaa bbbb'
assert_func plugin_params_validate "${TEST_FAIL}" "Icinga2 API status file is invalid or not readable"
CSL_USER_PARAMS_VALUES['ICINGA2_FILE']='icinga2.state'
assert_func plugin_params_validate "${TEST_OK}" "${TEST_EMPTY}"

CSL_USER_PARAMS+=( 'ICINGA2_HOST' )
CSL_USER_PARAMS_VALUES['ICINGA2_HOST']='xx xx'
assert_func plugin_params_validate "${TEST_FAIL}" "Invalid Icinga2 hostname provided"
CSL_USER_PARAMS_VALUES['ICINGA2_HOST']='localhost'
assert_func plugin_params_validate "${TEST_OK}" "${TEST_EMPTY}"
CSL_USER_PARAMS_VALUES['ICINGA2_HOST']='icinga.example.com'
assert_func plugin_params_validate "${TEST_OK}" "${TEST_EMPTY}"

CSL_USER_PARAMS+=( 'ICINGA2_PORT' )
CSL_USER_PARAMS_VALUES['ICINGA2_PORT']='aaaa bbbb'
assert_func plugin_params_validate "${TEST_FAIL}" "Invalid Icinga2 port provided"
CSL_USER_PARAMS_VALUES['ICINGA2_PORT']='localhost'
assert_func plugin_params_validate "${TEST_FAIL}" "Invalid Icinga2 port provided"
CSL_USER_PARAMS_VALUES['ICINGA2_PORT']='1234'
assert_func plugin_params_validate "${TEST_OK}" "${TEST_EMPTY}"

CSL_USER_PARAMS+=( 'ICINGA2_URI' )
CSL_USER_PARAMS_VALUES['ICINGA2_URI']='aaaa bbbb'
assert_func plugin_params_validate "${TEST_FAIL}" "Invalid Icinga2 URI provided"
CSL_USER_PARAMS_VALUES['ICINGA2_URI']='/v3'
assert_func plugin_params_validate "${TEST_OK}" "${TEST_EMPTY}"

CSL_USER_PARAMS+=( 'ICINGA2_PROTO' )
CSL_USER_PARAMS_VALUES['ICINGA2_PROTO']='aaaa bbbb'
assert_func plugin_params_validate "${TEST_FAIL}" "Invalid Icinga2 protocol provided"
CSL_USER_PARAMS_VALUES['ICINGA2_PROTO']='/v3'
assert_func plugin_params_validate "${TEST_FAIL}" "Invalid Icinga2 protocol provided"
CSL_USER_PARAMS_VALUES['ICINGA2_PROTO']='/123'
assert_func plugin_params_validate "${TEST_FAIL}" "Invalid Icinga2 protocol provided"
CSL_USER_PARAMS_VALUES['ICINGA2_PROTO']='http'
assert_func plugin_params_validate "${TEST_OK}" "${TEST_EMPTY}"
CSL_USER_PARAMS_VALUES['ICINGA2_PROTO']='https'
assert_func plugin_params_validate "${TEST_OK}" "${TEST_EMPTY}"

CSL_USER_PARAMS+=( 'ICINGA2_USER' )
CSL_USER_PARAMS_VALUES['ICINGA2_USER']='aaaa bbbb'
assert_func plugin_params_validate "${TEST_FAIL}" "Invalid Icinga2 user provided"
CSL_USER_PARAMS_VALUES['ICINGA2_USER']='test'
assert_func plugin_params_validate "${TEST_OK}" "${TEST_EMPTY}"

CSL_USER_PARAMS+=( 'ICINGA2_PASS' )
CSL_USER_PARAMS_VALUES['ICINGA2_PASS']='aaaa bbbb'
assert_func plugin_params_validate "${TEST_FAIL}" "Invalid Icinga2 password provided"
CSL_USER_PARAMS_VALUES['ICINGA2_PASS']='test'
assert_func plugin_params_validate "${TEST_OK}" "${TEST_EMPTY}"

CSL_USER_PARAMS+=( 'ICINGA2_CERT' )
CSL_USER_PARAMS_VALUES['ICINGA2_CERT']='aaaa bbbb'
assert_func plugin_params_validate "${TEST_FAIL}" "Invalid Icinga2 cert provided or the file is not readable"
CSL_USER_PARAMS_VALUES['ICINGA2_CERT']='test'
assert_func plugin_params_validate "${TEST_FAIL}" "Invalid Icinga2 cert provided or the file is not readable"
CSL_USER_PARAMS_VALUES['ICINGA2_CERT']='testCA/certs/host_crt.pem'
assert_func plugin_params_validate "${TEST_OK}" "${TEST_EMPTY}"

CSL_USER_PARAMS+=( 'ICINGA2_KEY' )
CSL_USER_PARAMS_VALUES['ICINGA2_KEY']='test aaa'
assert_func plugin_params_validate "${TEST_FAIL}" "Invalid Icinga2 key provided or the file is not readable"
CSL_USER_PARAMS_VALUES['ICINGA2_KEY']='test'
assert_func plugin_params_validate "${TEST_FAIL}" "Invalid Icinga2 key provided or the file is not readable"
CSL_USER_PARAMS_VALUES['ICINGA2_KEY']='testCA/private/host_key.pem'
assert_func plugin_params_validate "${TEST_OK}" "${TEST_EMPTY}"

CSL_USER_PARAMS+=( 'ICINGA2_CACERT' )
CSL_USER_PARAMS_VALUES['ICINGA2_CACERT']='test aaa'
assert_func plugin_params_validate "${TEST_FAIL}" "Invalid Icinga2 CA certificate provided or the file is not readable"
CSL_USER_PARAMS_VALUES['ICINGA2_CACERT']='test'
assert_func plugin_params_validate "${TEST_FAIL}" "Invalid Icinga2 CA certificate provided or the file is not readable"
CSL_USER_PARAMS_VALUES['ICINGA2_CACERT']='testCA/cacert.pem'
assert_func plugin_params_validate "${TEST_OK}" "${TEST_EMPTY}"

unset -v CSL_USER_PARAMS CSL_USER_PARAMS_VALUES CSL_USER_PARAMS_DEFAULT_VALUES
