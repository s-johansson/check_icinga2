#!/bin/bash

. common.sh

assert_func is_array $TEST_FAIL $TEST_EMPTY
assert_func is_array $TEST_FAIL $TEST_EMPTY bla
declare -g FOO=bar
assert_func is_array $TEST_FAIL $TEST_EMPTY FOO
assert_func is_array $TEST_FAIL $TEST_EMPTY bar
unset -v FOO
declare -a -g FOO=()
assert_func is_array $TEST_FAIL $TEST_EMPTY BAR
assert_func is_array $TEST_OK $TEST_EMPTY FOO
FOO+=( 'bar' )
assert_func is_array $TEST_OK $TEST_EMPTY FOO
assert_func is_array $TEST_FAIL $TEST_EMPTY BAR
unset -v TEST_ARY
