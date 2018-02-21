#!/usr/bin/env bash

# Copyright 2018 CivicActions, Inc.
# This program is licensed under the GNU Affero General
# Public License version 3.0 or any later version.
# License URL: https://www.gnu.org/licenses/agpl-3.0.en.html

# Binding Operational Directive (BOD) 18-01: https://cyber.dhs.gov/

# Check if server is using HTTPS Strict Transfer Security (HSTS).
# If HSTS, check if "includeSubDomains" and "preload" is included.
# Also check if weak ciphers are in use and if so, display them.

usage() {
  BASE=`basename $0`
  echo "Usage: $BASE SITENAME"
  echo "       If configured, displays: 'HSTS SubDomains preload SITENAME'"
  echo "       Followed by weak ciphers (if present)"
  echo "  Try: $BASE civicactions.com"
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
  HSTS="----"
  INCL="----------"
  LOAD="-------"
  CURL=$( curl -s -v "https://${SITE}" 2>&1 | grep Strict-Transport )
  if [[ ! -z "$CURL" ]]; then
    HSTS="HSTS"
    $( echo $CURL | grep "preload" > /dev/null ) && LOAD="preload"
    $( echo $CURL | grep -i "includeSubDomains" > /dev/null ) && INCL="SubDomains"
  fi
  CIPHER="$(sslscan $SITE | egrep '(SSLv|TLSv1.0|DES|RC4)')"
  if [[ -z "$CIPHER" ]]; then
    echo "$HSTS $INCL $LOAD $SITE -- uses strong ciphers!"
  else
    echo "$HSTS $INCL $LOAD $SITE -- weak ciphers listed below:"
    echo "$CIPHER" | sed 's/^/     /'
  fi
}

hsts "$1"
