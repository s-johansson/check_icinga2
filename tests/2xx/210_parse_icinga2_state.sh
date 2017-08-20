#!/bin/bash

. common.sh

assert_func parse_icinga2_status $TEST_FAIL 'The[[:blank:]]state-file[[:print:]]+is[[:blank:]]not[[:blank:]]readable[[:blank:]]or[[:blank:]]empty'
STATE_FILE="icinga2.state"
assert_func parse_icinga2_status $TEST_OK $TEST_EMPTY
unset -v STATE_FILE
assert_func parse_icinga2_status $TEST_FAIL 'Do[[:blank:]]not[[:blank:]]know[[:blank:]]for[[:blank:]]what[[:blank:]]state-file[[:blank:]]I[[:blank:]]should[[:blank:]]looking[[:blank:]]for'
