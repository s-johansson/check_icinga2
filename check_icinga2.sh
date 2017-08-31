#!/bin/bash

###############################################################################


# This file is part of check_icinga2 v1.0.
#
# check_icinga2, a monitoring plugin for (c) Icinga2.
#
# Copyright (C) 2017, Andreas Unterkircher <unki@netshadow.net>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# @author Andreas Unterkircher
# @license AGPLv3
# @title check_icinga2
# @version 1.0

set -u -e -o pipefail # exit-on-error, error on undeclared variables.
#shopt -s sourcepath  # in case Bash won't consider $PATH.

###############################################################################

PATH+=":/usr/share/monitoring-common-shell-library"

# shellcheck disable=SC1091
. functions.sh
[ "x${?}" == "x0" ] || \
   { fail "unable to include 'functions.sh'!"; exit 1; }

if [ $# -ge 1 ] && [ "${1}" == "-n" ]; then
   DO_NOT_RUN=true
   shift
fi

if ! is_func csl_require_libvers || \
   ! [[ "$(csl_require_libvers "1.5")" =~ ^(gt|eq)$ ]]; then
   echo "monitoring-common-shell-library v1.5 or higher is required."
   exit 1
fi

#
# <Variables>
#

readonly PROGNAME="check_icinga2"
readonly VERSION="1.0"

declare -g TMPDIR='' STATE_FILE=''
# shellcheck disable=SC2034
declare -g -a WELL_KNOWN_KEYS=(
   'counter'
   'crit'
   'label'
   'max'
   'min'
   'type'
   'unit'
   'value'
   'warn'
)
declare -g -A RESULTS=()


#
# </Variables>
#

add_param '-H:' --host:       ICINGA2_HOST localhost
add_param '-p:' --port:       ICINGA2_PORT 5665
add_param '-u:' --uri:        ICINGA2_URI  /v1/status
add_param '-f:' --file:       ICINGA2_FILE
add_param '-P:' --protocol:   ICINGA2_PROTO https
add_param '-U:' --user:       ICINGA2_USER
add_param '-W:' --password:   ICINGA2_PASS
add_param '-C:' --cert:       ICINGA2_CERT
add_param '-K:' --key:        ICINGA2_KEY
add_param '-A:' --cacert:     ICINGA2_CACERT

set_help_text <<EOF
${PROGNAME}, v${VERSION}

   -h, --help         ... help
   -v, --verbose      ... be more verbose.
   -d, --debug        ... enable debugging.
   -f, --file         ... use file as input instead of querying Icinga2 API

   -w, --warning=arg  ... warning threshold, see below THRESHOLDS section.
   -c, --critical=arg ... critical threshold, see below THRESHOLDS section.

Icinga2 API:

   -H, --host=arg     ... hostname, fqdn or address of the Icinga2 host
                          (default: localhost)
   -p, --port=arg     ... numeric port-number of the Icinga2 server
                          (default: 5665)
   -u, --uri=arg      ... URI of the Icinga2 API
                          (default: /v1/status)
   -P, --protocol=arg ... protocol to access Icinga2 API
                          (default: https)

Icinga2 API Authentication:

   -U, --user=arg     ... username for user-password logins
   -W, --password=arg ... password for user-password logins
   -C, --cert=arg     ... x509 SSL Certificate public key (in PEM format) for
                          certificate-based authentication
   -K, --key=arg      ... x509 SSL Certificate private key (in PEM format) for
                          certificate-based authentication
   -A, --cacert=arg   ... The CA certificate file (in PEM format) to validate
                          the retrieved API server certificated. This requires
                          HTTPS to access the Icinga2 API. You can use 'noverify'
                          as argument to this parameter, to disable verification.
                          Use --debug to get verbose output of curl.

THRESHOLDS are given similar to check_procs:

   * greater-than-or-equal-match (max) results in warning on:
      --warning :4
      --warning 4
   * less-than-or-equal-match (min) results in warning on:
      --warning 4:
   * inside-range-match (min:max)
      --warning 5:10
   * outside-range-match (max:min)
      --warning 10:5
EOF


###############################################################################


#
# <Functions>
#

# @function plugin_params_validate()
# @brief This functions validates the provided command-line parameters and
# returns 0, if the given arguments are valid. otherwise it returns 1.
# @return int
plugin_params_validate ()
{
   has_param_value ICINGA2_FILE && \
      debug "Input file: $(get_param_value ICINGA2_FILE)"
   has_param_value ICINGA2_HOST && \
      debug "Icinga2 host: $(get_param_value ICINGA2_HOST)"
   has_param_value ICINGA2_PORT && \
      debug "Icinga2 port: $(get_param_value ICINGA2_PORT)"
   has_param_value ICINGA2_URI && \
      debug "Icinga2 uri: $(get_param_value ICINGA2_URI)"
   has_param_value ICINGA2_PROTO && \
       debug "Icinga2 protocol: $(get_param_value ICINGA2_PROTO)"
   has_param_value ICINGA2_USER && \
       debug "Icinga2 user: $(get_param_value ICINGA2_USER)"
   has_param_value ICINGA2_PASS && \
       debug "Icinga2 pass: $(get_param_value ICINGA2_PASS)"
   has_param_value ICINGA2_CERT && \
       debug "Icinga2 cert: $(get_param_value ICINGA2_CERT)"
   has_param_value ICINGA2_KEY && \
      debug "Icinga2 key: $(get_param_value ICINGA2_KEY)"
   has_param_value ICINGA2_CACERT && \
      debug "Icinga2 cacert: $(get_param_value ICINGA2_CACERT)"

   #
   # Icinga2 host
   #
   if ! has_param_value ICINGA2_HOST || \
      ! [[ "$(get_param_value ICINGA2_HOST)" =~ ^[[:graph:]]+$ ]]; then
      fail "Invalid Icinga2 hostname provided. Allowed are only alpha-numeric and punctation characters!"
      return 1
   fi

   #
   # Icinga2 API port
   #
   if ! has_param_value ICINGA2_PORT || \
      ! [[ "$(get_param_value ICINGA2_PORT)" =~ ^[[:digit:]]+$ ]]; then
      fail "Invalid Icinga2 port provided. Allowed are only numeric characters!"
      return 1
   fi

   #
   # Icinga2 API status URI
   #
   if ! has_param_value ICINGA2_URI || \
      ! [[ "$(get_param_value ICINGA2_URI)" =~ ^[[:graph:]]+$ ]]; then
      fail "Invalid Icinga2 URI provided. Allowed are only alpha-numeric and punctation characters!"
      return 1
   fi

   #
   # Icinga2 API protocol
   #
   if ! has_param_value ICINGA2_PROTO || \
      ! [[ "$(get_param_value ICINGA2_PROTO)" =~ ^https?$ ]]; then
      fail "Invalid Icinga2 protocol provided. Allowed are only http or https!"
      return 1
   fi

   #
   # Icinga2 API authentication username
   #
   if has_param_value ICINGA2_USER && \
      ! [[ "$(get_param_value ICINGA2_USER)" =~ ^[[:graph:]]+$ ]]; then
      fail "Invalid Icinga2 user provided. Allowed are only alpha-numeric and punctation characters!"
      return 1
   fi

   #
   # Icinga2 API authentication password
   #
   if has_param_value ICINGA2_PASS && \
      ! [[ "$(get_param_value ICINGA2_PASS)" =~ ^[[:graph:]]+$ ]]; then
      fail "Invalid Icinga2 password provided. Allowed are only alpha-numeric and punctation characters!"
      return 1
   fi

   #
   # Icinga2 API x509 SSL certificate in PEM format
   #
   if has_param_value ICINGA2_CERT && ( \
      ! [[ "$(get_param_value ICINGA2_CERT)" =~ ^[[:graph:]]+$ ]] || \
      [ ! -r "$(get_param_value ICINGA2_CERT)" ] ); then
      fail "Invalid Icinga2 cert provided or the file is not readable. Allowed are only alpha-numeric and punctation characters!"
      return 1
   fi

   #
   # Icinga2 API x509 SSL certificate
   #
   if has_param_value ICINGA2_KEY && ( \
      ! [[ "$(get_param_value ICINGA2_KEY)" =~ ^[[:graph:]]+$ ]] || \
      [ ! -r "$(get_param_value ICINGA2_KEY)" ] ); then
      fail "Invalid Icinga2 key provided or the file is not readable. Allowed are only alpha-numeric and punctation characters!"
      return 1
   fi

   #
   # Icinga2 API x509 SSL CA certificate
   #
   if has_param_value ICINGA2_CACERT && ( \
      ! [[ "$(get_param_value ICINGA2_CACERT)" =~ ^[[:graph:]]+$ ]] || ( \
      [ "$(get_param_value ICINGA2_CACERT)" != "noverify" ] && \
      [ ! -r "$(get_param_value ICINGA2_CACERT)" ] ) ); then
      fail "Invalid Icinga2 CA certificate provided or the file is not readable. Allowed are only alpha-numeric and punctation characters!"
      return 1
   fi

   #
   # Icinga2 API status as file.
   #
   if has_param_value ICINGA2_FILE && ( \
      ! [[ "$(get_param_value ICINGA2_FILE)" =~ ^[[:print:]]+$ ]] || \
      [ ! -r "$(get_param_value ICINGA2_FILE)" ] ); then
      fail "Invalid Icinga2 API status file is not readable.!"
      return 1
   fi

   return 0
}

# @function plugin_worker()
# @brief This function gets kicked by the monitoring-common-shell-library
# as entry point to this plugin. If a state-file has been provided (--file),
# that one is used as input information. Otherwise it calls fetch_icinga2_status()
# to retrieve a fresh status information. Afterwards it parses and evalautes the
# retrieved informations.
# @return int
plugin_worker ()
{
   add_prereq jq

   if ! has_param_value ICINGA2_FILE; then
      fetch_icinga2_status || \
         { fail "fetch_icinga2_status() returned non-zero!"; exit 1; }
   fi

   parse_icinga2_status || \
      { fail "parse_icinga2_status() returned non-zero!"; exit 1; }

   if ! is_array RESULTS || [ ${#RESULTS[@]} -lt 1 ]; then
      fail "No valid Icinga2 status was retrieved!"
      exit 1
   fi

   eval_icinga2_status || \
      { fail "eval_icinga2_status() returned non-zero!"; exit 1; }
}

# @function fetch_icinga2_status()
# @brief This function retrieves the Icinga2 state informations
# and counters via the Icinga2 API. It utilizes 'curl' to access
# the API via HTTP or HTTPS. On success, it returns 0, otherwise 1.
# @return int
fetch_icinga2_status ()
{
   local QUERY_URI="" RETVAL=
   local -a CURL_OPT=()

   #
   # Query URI
   #

   if ! has_param_value ICINGA2_FILE && ( \
      ! has_param_value ICINGA2_HOST || \
      ! has_param_value ICINGA2_PORT || \
      ! has_param_value ICINGA2_URI || \
      ! has_param_value ICINGA2_PROTO ); then
      fail "Not all required parameters are set!"
      return 1
   fi

   QUERY_URI+="$(get_param_value ICINGA2_PROTO)://"
   QUERY_URI+="$(get_param_value ICINGA2_HOST)"
   QUERY_URI+=":$(get_param_value ICINGA2_PORT)"
   QUERY_URI+="$(get_param_value ICINGA2_URI)"

   if ! [[ "${QUERY_URI}" =~ ^https?://[[:graph:]]+$ ]]; then
      fail "An invalid looking query URI was generated using the provided Icinga2 parameters!"
      return 1
   fi

   debug "Will query Icinga2 state at: ${QUERY_URI}"

   #
   # Authentication
   #

   if has_param_value ICINGA2_USER && ! has_param_value ICINGA2_PASS || \
      ! has_param_value ICINGA2_USER && has_param_value ICINGA2_PASS; then
      fail "Incomplete user credentials provided!"
      return 1
   fi

   if has_param_value ICINGA2_CERT && ! has_param_value ICINGA2_KEY || \
      ! has_param_value ICINGA2_CERT && has_param_value ICINGA2_KEY; then
      fail "Incomplete cert/key provided!"
      return 1
   fi

   #
   # basic-authentication via curl+netrc
   # so the password is _not_ visible as
   # command-line parameter.
   #
   if has_param_value ICINGA2_USER; then
      cat >${TMPDIR}/.netrc <<-EOF
      machine $(get_param_value ICINGA2_HOST) login $(get_param_value ICINGA2_USER) password $(get_param_value ICINGA2_PASS)
EOF
      CURL_OPT+=( "--netrc-file" "${TMPDIR}/.netrc" )
   fi

   #
   # certificate-authentication
   #
   if has_param_value ICINGA2_CERT; then
      CURL_OPT+=( "--cert" "$(get_param_value ICINGA2_CERT)" )
      CURL_OPT+=( "--key" "$(get_param_value ICINGA2_KEY)" )
   fi

   if has_param_value ICINGA2_CACERT; then
      local CACERT
      CACERT="$(get_param_value ICINGA2_CACERT)"
      # disable SSL server cert verification, take at your own risk!
      if [ "${CACERT}" == "noverify" ]; then
         CURL_OPT+=( "--insecure" )
      else
         CURL_OPT+=( "--cacert" "${CACERT}" )
      fi
   fi

   debug "Will authenticate at Icinga2 API with: ${CURL_OPT[*]}"

   CURL_OPT+=( "--output" "${STATE_FILE}" )

   if is_debug; then
      CURL_OPT+=( "--verbose" )
   else
      CURL_OPT+=( "--silent" )
   fi

   curl "${CURL_OPT[@]}" "${QUERY_URI}"
   RETVAL=$?

   if [ "x${RETVAL}" != "x0" ]; then
      fail "Failed to query Icinga2 API! Curl exited non-zero (${RETVAL}) (check 'man curl' what it means)."
      return 1
   fi

   if [ ! -s "${STATE_FILE}" ]; then
      fail "Curl returned successfully, but the Icinga2 state-file is empty!"
      return 1
   fi

   return "${RETVAL}"
}

# @function parse_icinga2_status()
# @brief This function parses the $STATE_FILE (either a locally stored one,
# or a fresh, retrieved from the Icinga2 API.
# The parsed information gets stored into the $RESULT associative array and
# will later be handled by eval_icinga2_status(). On success, it returns 0.
# Otherwise it will return 1.
# @return 1
parse_icinga2_status ()
{
   if ! is_declared STATE_FILE || is_empty STATE_FILE; then
      fail "Do not know for what state-file I should looking for???"
      return 1
   fi

   if [ ! -s "${STATE_FILE}" ]; then
      fail "The state-file '${STATE_FILE}' is not readable or empty!"
      return 1
   fi

   local LABEL='' KEY='' VALUE='' LINE='' RETVAL
   local -A READING=()
   local -a LABELS=() READINGS=()

   RESULTS=()

   #
   # first lookout for everything that looks like performance statistics
   #
   mapfile -t LABELS < <(jq -M -r .results[].perfdata[].label < ${STATE_FILE})
   RETVAL="${?}"

   if [ "x${RETVAL}" != "x0" ]; then
      echo "'jq' or 'mapfile' exited non-zero (${RETVAL})!."
      return 1
   fi

   if ! is_array LABELS || [ ${#LABELS[@]} -lt 1 ]; then
      fail "Failed to parse JSON data in ${STATE_FILE}!"
      return 1
   fi

   #
   # retrieve
   #
   for LABEL in "${LABELS[@]}"; do
      mapfile -t READINGS < <(jq -M -j ".results[].perfdata[] | select(.label == \"${LABEL}\")" < ${STATE_FILE})
      RETVAL="${?}"

      if [ "x${RETVAL}" != "x0" ]; then
         echo "'jq' or 'mapfile' exited non-zero (${RETVAL})!."
         return 1
      fi

      if ! is_array READINGS || [ ${#READINGS[@]} -lt 1 ]; then
         fail "Failed to fetch labels from ${STATE_FILE}!"
         return 1
      fi

      # debug "${READINGS[*]}"

      READING=()
      for LINE in "${READINGS[@]}"; do

         if ! [[ "${LINE}" =~ ^[[:blank:]]*\"?([[:graph:]][^\"]?+)\"?:[[:blank:]]*\"?([[:print:]]*[^\",])[[:blank:]]?\"?,? ]]; then
            continue
         fi

         if [ ${#BASH_REMATCH[@]} -lt 1 ]; then
            continue
         fi

         [ -n "${BASH_REMATCH[1]}" ] || { fail "Got an empty key!"; return 1; }

         KEY="${BASH_REMATCH[1]}"
         VALUE="${BASH_REMATCH[2]//null/}"

         if ! in_array WELL_KNOWN_KEYS "${KEY}"; then
            verbose "Got an unknown perfdata key '${KEY}' - you might want to add it to WELL_KNOWN_KEYS"
         fi

         debug "Found ${LABEL}[${KEY}]=${VALUE}"
         READING[${KEY}]="${VALUE}"
      done

      [ ${#READING[@]} -gt 0 ] || continue

      [[ -v "READING[label]" ]] || { fail "Label not set!"; return 1; }
      [[ -v "READING[value]" ]] || { fail "Value not set!"; return 1; }
      # have no idea yet, why the above regexp returns a ' ' for zero-string values
      # so clear it.
      [[ -v "READING[unit]" ]] && [[ "${READING['unit']}" =~ ^[[:blank:]]+$ ]] && READING['unit']=''

      ! [[ -v "RESULTS[${LABEL}]" ]] || { debug "Possible duplicate key '${KEY}'. Skipping it."; continue; }

      RESULTS["${LABEL}"]="${READING['value']}${READING['unit']-};${READING['warn']-};${READING['crit']-};${READING['min']-};${READING['max']-}"
   done

   #
   # next the CIB statistics - have no clue what CIB means :)
   #
   READINGS=()
   mapfile -t READINGS < <(jq -M -j ".results[] | select(.name == \"CIB\") | .status" < ${STATE_FILE})
   RETVAL="${?}"

   if [ "x${RETVAL}" != "x0" ]; then
      echo "'jq' or 'mapfile' exited non-zero (${RETVAL})!."
      return 1
   fi

   if ! is_array READINGS || [ ${#READINGS[@]} -lt 1 ]; then
      fail "Failed to fetch CIB from ${STATE_FILE}!"
      return 1
   fi

   for LINE in "${READINGS[@]}"; do

      if ! [[ "${LINE}" =~ ^[[:blank:]]*\"?([[:graph:]][^\"]?+)\"?:[[:blank:]]*\"?([[:print:]]*[^\",])[[:blank:]]?\"?,? ]]; then
         continue
      fi

      if [ ${#BASH_REMATCH[@]} -lt 1 ]; then
         continue
      fi

      [ -n "${BASH_REMATCH[1]}" ] || { fail "Got an empty key!"; return 1; }

      KEY="${BASH_REMATCH[1]}"
      VALUE="${BASH_REMATCH[2]//null/}"

      [ ! -z "${VALUE}" ] || { debug "Skipping key '${KEY}' with an empty value."; continue; }

      if ! [[ "${KEY}" =~ ^(active_(host|service)_|avg_|min_|max_|num_(hosts|services)_|passive_(service|host)_|uptime) ]]; then
         debug "Skipping unknown key '${KEY}'."
      fi

      debug "Found ${KEY}=${VALUE}"
      ! [[ -v "RESULTS[${KEY}]" ]] || { debug "Possible duplicate key '${KEY}'. Skipping it."; continue; }

      RESULTS["${KEY}"]="${VALUE}"
   done

   return 0
}

# @function eval_icinga2_status()
# @brief This function evaluates the parsed heath-information that
# has been previously stored in $RESULTS.
# TODO At the moment, that is actually not matching against thresholds.
# Just OK if state-information exists, otherwise it issues a WARNING.
# @return int
eval_icinga2_status ()
{
   if ! is_array RESULTS || [ ${#RESULTS[@]} -lt 1 ]; then
      set_result_text "No Icinga2 state is available!"
      set_result_code "${CSL_EXIT_WARNING}"
      return "${CSL_EXIT_WARNING}"
   fi

   local RESULT_PERFC=""
   for KEY in "${!RESULTS[@]}"; do
      [ ! -z "${KEY}" ] || continue
      [ ! -z "${RESULTS[${KEY}]}" ] || continue
      RESULT_PERFC+="'${KEY}'=${RESULTS[${KEY}]} "
   done

   if [ ${#RESULT_PERFC} -gt 0 ]; then
      set_result_perfdata "${RESULT_PERFC:0:-1}"
   fi

   set_result_text "OK"
   set_result_code "${CSL_EXIT_OK}"
}

# @function plugin_startup()
# @brief This function gets invoked by the monitoring-common-shell-library.
# In our case, it requests a temporary directory from the library and installs
# a cleanup trap, that tries to ensure, that any residues in the filesystem get
# removed.
# @return int
plugin_startup ()
{
   TMPDIR="$(create_tmpdir)"
   setup_cleanup_trap;

   STATE_FILE="${TMPDIR}/icinga2.state"

   if has_param_value ICINGA2_FILE; then
      STATE_FILE="$(get_param_value ICINGA2_FILE)"
   fi

   [ ! -z "${TMPDIR}" ] || { fail "Failed to create temporary directory in /tmp!"; return 1; }
}

#
# </Functions>
#

#
# <TheActualWorkStartsHere>
#
! [[ -v DO_NOT_RUN ]] || return 0
startup "${@}"


#
# normally our script should have exited in print_result() already.
# so we should not get to this end at all.
# Anyway we exit with $CSL_EXIT_UNKNOWN in case.
#
exit "${CSL_EXIT_UNKNOWN}"

#
# </TheActualWorkStartsHere>
#
