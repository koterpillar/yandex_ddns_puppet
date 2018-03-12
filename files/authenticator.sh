#!/bin/sh

set -e

. $(dirname $0)/functions.sh

. $(dirname $0)/cleanup.sh

add_record $RECORD TXT $CERTBOT_VALIDATION
