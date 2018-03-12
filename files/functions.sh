. $(dirname $0)/environment

BASE_URL=https://pddimp.yandex.ru/api2/admin/dns

request () {
    url="$1"
    shift
    curl -s -H "PddToken: $TOKEN" $BASE_URL/$url -d "domain=$DOMAIN" "$@"
}

get_record_id () {
    record_type=$1
    subdomain=$2
    result_type=${3:-record_id}

    if [ -n "$subdomain" ]
    then
        subdomain_filter='| select(.subdomain == "'$subdomain'")'
    else
        subdomain_filter=''
    fi

    filter='.records[] | select(.type == "'$record_type'") '$subdomain_filter' | .'$result_type''
    request list -XGET | jq -r "$filter"
}

delete_record () {
    record_id=$1
    request del -d "record_id=$record_id"
}

add_record () {
    subdomain=$1
    record_type=$2
    content=$3

    request add \
            -d type=$record_type \
            -d subdomain=$subdomain \
            -d content=$content
}
