#!/usr/bin/env bash

# Copyright 2018 CivicActions, Inc.
# This program is licensed under the GNU Affero General
# Public License version 3.0 or any later version.
# License URL: https://www.gnu.org/licenses/agpl-3.0.en.html

# Binding Operational Directive (BOD) 18-01: https://cyber.dhs.gov/

# Check if server is using HTTPS Strict Transfer Security (HSTS).
# If HSTS, check if "includeSubDomains" and "preload" is included.
# Also check if weak ciphers are in use and if so, display them.

BASE=`basename $0`

usage() {
  echo "Usage: $BASE SITENAME [BASIC:AUTH@] [PATH]"
  echo "       If configured, displays: 'HSTS SubDomains preload SITENAME'"
  echo "       Followed by weak protocols (TLSv1.0, TLSv1.1) and ciphers (DES, RC4)."
  echo "       For more complete SSL information, run 'sslscan SITENAME'"
  echo "  Try: $BASE civicactions.com"
  echo "   Or: $BASE badssl.com"
  exit 1
}
[[ $# -eq 0 ]] && usage

MINV="1.11"
minversion() {
  echo "$BASE requires sslscan v${MINV}+ to be installed on your system"
  echo "Install with (e.g.) 'pacaur -S sslscan-git'"
  exit 1
}
# Make sure sslscan is installed.
$( command -v sslscan > /dev/null ) || minversion

# Confirm that sslscan is at least MINV (1.11).
version_gt() { test "$(printf '%s\n' "$@" | sort -V  | head -n 1)" != "$1"; }
VERS="$(sslscan --version | egrep 'static|version' | sed 's/.*\s\([0-9][0-9\.]*\).*$/\1/')"
version_gt $MINV $VERS && minversion

hsts() {
  SITE="$1"
  AUTH="$2"
  POST="$3"
  HSTS="----"
  INCL="----------"
  LOAD="-------"
  TIME=5
  # Check for HTTPS Strict Transport Security (HSTS).
  CURL=$( curl --connect-timeout $TIME -s -v "https://${AUTH}${SITE}/${POST}" 2>&1 )
  ERROR=$?
  if [[ $ERROR -ne 0 ]]; then
    case $ERROR in
      6)
	ETEXT="Couldn't resolve host."
	;;
      28)
	ETEXT="Site timeout after $TIME seconds"
	;;
      35)
	ETEXT="SSL connect error. The SSL handshaking failed"
	;;
      60)
	ETEXT="Peer certificate cannot be authenticated with known CA certificates"
	;;
      *)
	ETEXT="Curl connection error code: $ERROR"
    esac
    echo "$HSTS $INCL $LOAD -Error- $SITE -- $ETEXT"
    return
  fi
  STRICT=$( echo $CURL | grep -i strict-transport )
  if [[ ! -z "$STRICT" ]]; then
    HSTS="HSTS"
    $( echo $STRICT | grep -i "preload" > /dev/null ) && LOAD="preload"
    $( echo $STRICT | grep -i "includesubdomains" > /dev/null ) && INCL="SubDomains"
  fi
  # Check for weak protocols and ciphers.
  SSLSCAN="$(sslscan $SITE | egrep '(SSLv|TLSv1.|DES|RC4)')"
  PROTOS=''
  CIPHERS=''
  TLSv12='-------'
  TLSv13=''
  $(echo $SSLSCAN | grep -q 'SSLv')    && PROTOS="$PROTOS SSL"
  $(echo $SSLSCAN | grep -q 'TLSv1.0') && PROTOS="$PROTOS TLSv1.0"
  $(echo $SSLSCAN | grep -q 'TLSv1.1') && PROTOS="$PROTOS TLSv1.1"
  $(echo $SSLSCAN | grep -q 'DES')     && CIPHERS="$CIPHERS DES"
  $(echo $SSLSCAN | grep -q 'RC4')     && CIPHERS="$CIPHERS RC4"
  $(echo $SSLSCAN | grep -q 'TLSv1.2') && TLSv12="TLSv1.2"
  $(echo $SSLSCAN | grep -q 'TLSv1.3') && TLSv13="(has TLSv1.3)"
  WEAK=''
  [[ -z "$PROTOS" ]]  || WEAK="weak protocol:$PROTOS"
  [[ -z "$CIPHERS" ]] || WEAK="$WEAK; weak cipher:$CIPHERS"
  [[ -z "$WEAK" ]]    || WEAK="-- $WEAK"
  [[ -z "$TLSv13" ]]  || WEAK="$WEAK $TLSv13"
  echo "$HSTS $INCL $LOAD $TLSv12 $SITE ${WEAK}"
}

hsts "$1"
