#!/usr/bin/env bash

# Copyright 2018-2020 CivicActions, Inc.
# This program is licensed under the GNU Affero General
# Public License version 3.0 or any later version.
# License URL: https://www.gnu.org/licenses/agpl-3.0.en.html

# Binding Operational Directive (BOD) 18-01: https://cyber.dhs.gov/bod/18-01/

# Check if server is using HTTPS Strict Transfer Security (HSTS).
# If HSTS is configured, check that max-age is >= 31536000 (365 days)
#         and look for the "includeSubDomains" and "preload" flags.
# Finally, confirm the availablility of TLSv1.2 and check for weak ciphers.

BASE=`basename $0`

[[ $# -eq 0 ]] && {
  echo "Usage: $BASE [ 'header' ] SITENAME..."
  echo "       If arg is 'header', print a header for output; then for each SITENAME:"
  echo "       If configured, displays: 'HSTS SubDomains preload TLSv1.2 SITENAME'"
  echo "       Followed by weak protocols (TLSv1.0, TLSv1.1) and ciphers (DES, RC4)."
  echo "       Indicate 'max-age' if less than 31536000 (365 days) and HSTS is set."
  echo "       Note that SITENAME can contain AUTH (user:pass@) and an optional /PATH"
  echo "       For more complete SSL information, run 'sslscan SITENAME'"
  echo "  Try: $BASE header civicactions.com github.com badssl.com"
  exit 1
}

MINV="2.0"
minversion() {
  echo "$BASE requires sslscan v${MINV}+ to be installed on your system"
  echo "Clone and compile from https://github.com/rbsec/sslscan"
  exit 1
}
# Make sure sslscan is installed.
$( command -v sslscan > /dev/null ) || minversion

# Confirm that sslscan is at least MINV (1.11).
version_gt() { test "$(printf '%s\n' "$@" | sort -V  | head -n 1)" != "$1"; }
VERS="$(sslscan --version | egrep 'static|version' | sed 's/.*\s\([0-9][0-9\.]*\).*$/\1/')"
version_gt $MINV $VERS && minversion

# Print a header.
print_header() {
  echo "HSTS SubDomains Preload TLSv12? Sitename [-- weak protocols, ciphers, max-age]"
  echo "==== ========== ======= ======= ========"
}

hsts() {
  ARG=$1
  [[ $ARG == "header" ]] && {
    print_header
    return
  }
  # Strip optional "AUTH@" and "/POST" from $SITE (there must be a better way).
  SITE="$ARG"
  [[ $SITE =~ "@" ]] && SITE=$( echo $SITE | cut -d'@' -f2 )
  [[ $SITE =~ "/" ]] && SITE=$( echo $SITE | cut -d'/' -f1 )
  # Set negative defaults.
  HSTS="----"
  INCL="----------"
  LOAD="-------"
  TIME=10
  # Check for HTTPS Strict Transport Security (HSTS).
  CURL=$( curl --connect-timeout $TIME -s -v "https://${ARG}" 2>&1 )
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
      51)
	ETEXT="The peer's SSL certificate or SSH MD5 fingerprint was not OK."
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
  MAXAGE=''
  STRICT=$( echo "$CURL" | grep -i "strict-transport-security" )
  if [[ ! -z "$STRICT" ]]; then
    HSTS="HSTS"
    $( echo $STRICT | grep -i "preload" > /dev/null ) && LOAD="preload"
    $( echo $STRICT | grep -i "includesubdomains" > /dev/null ) && INCL="SubDomains"
    $( echo $STRICT | grep -i "max-age=" > /dev/null ) && {
      MAX=31536000
      AGE=$( echo "$STRICT" | sed 's/.*max-age=\([0-9]*\).*$/\1/' )
      (( $AGE < $MAX )) && MAXAGE="max-age=${AGE}(<${MAX})"
    }
  fi
  # Check for weak protocols and ciphers.
  SSLSCAN="$(sslscan --no-colour --bugs --no-heartbleed --no-compression --no-renegotiation --no-check-certificate $SITE)"
  PROTOS=''
  CIPHERS=''
  TLSv12='-------'
  TLSv13=''
  $(echo "$SSLSCAN" | egrep -q '^SSLv.*\s+enabled')  && PROTOS="$PROTOS SSL"
  $(echo "$SSLSCAN" | egrep -q '^TLSv1.0\s+enabled') && PROTOS="$PROTOS TLSv1.0"
  $(echo "$SSLSCAN" | egrep -q '^TLSv1.1\s+enabled') && PROTOS="$PROTOS TLSv1.1"
  $(echo "$SSLSCAN" | grep -q 'DES')                 && CIPHERS="$CIPHERS DES"
  $(echo "$SSLSCAN" | grep -q 'RC4')                 && CIPHERS="$CIPHERS RC4"
  $(echo "$SSLSCAN" | egrep -q '^TLSv1.2\s+enabled') && TLSv12="TLSv1.2"
  $(echo "$SSLSCAN" | egrep -q '^TLSv1.3\s+enabled') && TLSv13="(has TLSv1.3)"
  WEAK=''
  [[ -z "$PROTOS" ]]  || WEAK="weak protocol:$PROTOS"
  [[ -z "$CIPHERS" ]] || WEAK="$WEAK; weak cipher:$CIPHERS"
  [[ -z "$WEAK" ]]    || WEAK="-- $WEAK"
  [[ -z "$TLSv13" ]]  || WEAK="$WEAK $TLSv13"
  [[ -z "$MAXAGE" ]]  || WEAK="${WEAK}; ${MAXAGE}"
  echo "$HSTS $INCL $LOAD $TLSv12 $SITE ${WEAK}"
}

for ARG in "$@"; do
  hsts "$ARG"
done
