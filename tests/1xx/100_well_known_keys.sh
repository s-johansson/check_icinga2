#!/bin/bash

. common.sh

assert_equals ${WELL_KNOWN_KEYS[0]} 'counter' 
assert_equals ${WELL_KNOWN_KEYS[-1]} 'warn' 
