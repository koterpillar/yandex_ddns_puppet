#!/bin/sh

set -e

. $(dirname $0)/functions.sh

if [ "$CERTBOT_DOMAIN" = "$DOMAIN" ]
then
    SUBDOMAIN=
    RECORD=_acme-challenge
else
    SUBDOMAIN=$(echo $CERTBOT_DOMAIN | sed -E 's/\..+//g')
    RECORD=_acme-challenge.$SUBDOMAIN
fi

existing=$(get_record_id TXT $RECORD)
if [ -n "$existing" ]
then
    delete_record $existing
fi
