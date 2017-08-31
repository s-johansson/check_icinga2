#!/bin/bash

. common.sh

assert_func fetch_icinga2_status "${TEST_FAIL}" "Failed to query Icinga2 API! Curl exited non-zero"
