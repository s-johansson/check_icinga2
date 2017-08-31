#!/bin/bash

. common.sh

assert_func plugin_worker "${TEST_FAIL}" "Failed to query Icinga2 API! Curl exited non-zero"
