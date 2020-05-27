#!/bin/bash

XURL="${1}"
XDBUSER="${2}"
XDBPASS="${3}"
XDBNAME="${4}"
XPREFIX="${5}"

if [ -z "${XURL}" ] || [ -z "${XDBUSER}" ] || [ -z "${XDBPASS}" ] || [ -z "${XDBNAME}" ]; then
	echo "usage: ${0} url dbuser dbpass dbname [tableprefix]"
	echo "       tableprefix default = 'wp_'"
	exit 1
fi

if [ -z "${XPREFIX}" ]; then
	XPREFIX="wp_"
fi

echo "update ${XPREFIX}options set option_value='${XURL}' WHERE option_name IN ('siteurl','home');" | mysql "--user=${XDBUSER}" "--password=${XDBPASS}" "${XDBNAME}"
