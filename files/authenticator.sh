#!/bin/sh

set -e

. $(dirname $0)/functions.sh

. $(dirname $0)/cleanup.sh

add_txt_record $RECORD $CERTBOT_VALIDATION
