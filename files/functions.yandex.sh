. $(dirname $0)/environment

BASE_URL=https://pddimp.yandex.ru/api2/admin/dns

request () {
    url="$1"
    shift
    curl -s -H "PddToken: $TOKEN" $BASE_URL/$url -d "domain=$DOMAIN" "$@"
}

get_record_attr () {
    record_type=$1
    subdomain=$2
    attr=$3

    if [ -n "$subdomain" ]
    then
        subdomain_filter='| select(.subdomain == "'$subdomain'")'
    else
        subdomain_filter=''
    fi

    filter='.records[] | select(.type == "'$record_type'") '$subdomain_filter' | .'$attr''
    request list -XGET | jq -r "$filter"
}

get_record_id () {
    record_type=$1
    subdomain=$2
    get_record_attr $record_type $subdomain 'record_id'
}

get_record_ip () {
    record_type=$1
    subdomain=$2
    get_record_attr $record_type $subdomain 'content'
}

get_record_content () {
    record_type=$1
    subdomain=$2
    get_record_attr $record_type $subdomain 'content'
}

delete_record () {
    record_id=$1
    request del -d "record_id=$record_id"
}

add_txt_record () {
    subdomain=$1
    content=$2

    request add \
            -d type=$record_type \
            -d subdomain=$subdomain \
            -d content=$content
}

ensure_cname () {
    subdomain=$1
    current_target=$(get_record_attr CNAME content)

    if [ "$current_target" != "$DOMAIN." ]
    then
        add_record $subdomain CNAME $DOMAIN.
    fi
}

set_record_ip () {
    record_id=$1
    ip=$2

    request edit -d "domain=$DOMAIN&record_id=$record_id&content=$ip"
}
