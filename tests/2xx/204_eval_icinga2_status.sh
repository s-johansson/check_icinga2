#!/bin/bash

. common.sh

unset -v RESULTS
assert_func eval_icinga2_status "${TEST_FAIL}" "${TEST_EMPTY}"
declare -a RESULTS=( '1' '2' '3' )
assert_func eval_icinga2_status "${TEST_OK}" "${TEST_EMPTY}"
unset -v RESULTS
assert_func eval_icinga2_status "${TEST_FAIL}" "${TEST_EMPTY}"
