#!/bin/sh

set -e

. $(dirname $0)/functions.sh

SUBDOMAIN=$(echo $CERTBOT_DOMAIN | sed -E 's/\..+//g')

RECORD=_acme-challenge.$SUBDOMAIN

existing=$(get_record_id TXT $RECORD)
if [ -n "$existing" ]
then
    delete_record $existing
fi
