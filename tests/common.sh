#!/bin/bash

#
# include the plugin.
#
source ../check_icinga2.sh -n
[ "x${?}" == "x0" ] || \
   { echo "Failed to load check_icinga2.sh! Exiting..."; exit 1; }

#
# restore some settings that have been made by function.sh
#
set +e +o pipefail

#
# a counter for numbering each test that gets executed.
#
declare -p "TEST_NUM" &>/dev/null || declare -g TEST_NUM=0
export TEST_NUM

#readonly CWD=$(dirname $(realpath $0))

# we use a place holder to signalize no output is desired.
readonly TEST_EMPTY="xxxxxxLANGWEILIGxxxxxx"

# boolean exit states
readonly TEST_TRUE=0
readonly TEST_FALSE=1

# regular exit states
readonly TEST_OK=0
readonly TEST_FAIL=1
readonly TEST_WARNING=1
readonly TEST_CRITICAL=2
readonly TEST_UNKNOWN=3

declare TEST_DEBUG=false

if [ $# -gt 0 ] && [ "x${1}" == "x--debug" ]; then
   TEST_DEBUG=true
fi

do_debug ()
{
   ${TEST_DEBUG} || return 0
   echo "$@"
}

assert_equals ()
{
   local PARAM1="${1}"
   local PARAM2="${2}"
   local EXPECT="0"

   if [ $# -eq 3 ]; then
      [ ! -z "${3}" ] && EXPECT=${3}
   fi

   TEST_NUM=$((TEST_NUM + 1))
   do_debug -n "Test ${TEST_NUM}: "

   [[ ${PARAM1} =~ ${PARAM2} ]]
   RETVAL=$?

   if [[ ${RETVAL} =~ ${EXPECT} ]]; then
      do_debug "PASS"
     return 0
   fi

   echo "NUM:   ${TEST_NUM} (${FUNCNAME[0]}: ${@})"
   echo "FAIL:  expected ${EXPECT} but got ${RETVAL}!"
   echo

   exit 1
}

assert_limits ()
{
   local RETVAL= RESULT= EXPECT_TEXT=
   local EXPECT_CODE="${1}"; shift

   case "${EXPECT_CODE}" in
      0) EXPECT_TEXT="OK" ;;
      1) EXPECT_TEXT="WARNING" ;;
      2) EXPECT_TEXT="CRITICAL" ;;
      *) EXPECT_TEXT="UNKNOWN" ;;
   esac

   assert_func eval_limits $EXPECT_CODE $EXPECT_TEXT "$@"
   return $?
}

assert_func ()
{
   local RETVAL= RESULT=
   local FUNC="${1}"; shift
   local EXPECT_CODE="${1}"; shift
   local EXPECT_TEXT="${1}"; shift
   local FAIL_TEXT= FAIL_ON_EXIT= FAIL_ON_TEXT=

   TEST_NUM=$((TEST_NUM + 1))
   do_debug -n "Test ${TEST_NUM}: "

   RESULT=$($FUNC "${@}" 2>&1)
   RETVAL=$?

   if [[ ${RETVAL} =~ ${EXPECT_CODE//[[:blank:]]/[[:blank:]]} ]] && \
      ( ( [ "${EXPECT_TEXT}" == "${TEST_EMPTY}" ] && [ -z "${RESULT}" ] ) || \
      [[ "${RESULT}" =~ ${EXPECT_TEXT} ]] ); then
      do_debug "PASS"
      return 0
   fi

   if ! [[ ${RETVAL} =~ ${EXPECT_CODE} ]]; then
      FAIL_TEXT+="Expected exit-code '${EXPECT_CODE}', but got '${RETVAL}'!\n\t"
   fi

   if [ "${EXPECT_TEXT}" != "${TEST_EMPTY}" ] && ! [[ "${RESULT}" =~ ${EXPECT_TEXT} ]]; then
      FAIL_TEXT+="Expected output '${EXPECT_TEXT}', but got '${RESULT//[^a-zA-Z0-9_[:blank:][:punct:]]/}'!\n\t"
   fi

   if [ "${EXPECT_TEXT}" == "${TEST_EMPTY}" ] && [ ! -z "${RESULT}" ]; then
      FAIL_TEXT+="Expected no output, but got '${RESULT//[^a-zA-Z0-9_[:blank:][:punct:]]/}'!\n\t"
   fi

   echo "FAILED"; echo
   echo -e "TEST:\tNo.${TEST_NUM} (${FUNCNAME[0]}:${BASH_LINENO[0]})"
   echo -e "PARAM:\t${@}"
   [ ! -z "${FAIL_TEXT}" ] && echo -e "ERR:\t${FAIL_TEXT:0:-4}"
   echo

   exit 1
}
