. $(dirname $0)/environment

BASE_URL=https://api.1cloud.ru/dns

request () {
    url="$1"
    shift
    curl -s -H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" $BASE_URL/$url "$@"
}

get_domain_id () {
    request '' -XGET | jq -r '.[] | select(.Name == "'$DOMAIN'") | .ID'
}

get_record_attr () {
    record_type=$1
    subdomain=$2
    attr=$3

    base_filter='.[] | select(.Name == "'$DOMAIN'") | .LinkedRecords[]'

    case $record_type in
        A|CNAME)
            subdomain_key=MnemonicName
            ;;
        TXT)
            subdomain_key=HostName
            ;;
        *)
            echo "Unknown record_type $record_type." >&2
            exit 1
            ;;
    esac

    if [ -n "$subdomain" ]
    then
        subdomain_filter='| select(.'$subdomain_key' == "'$subdomain'.'$DOMAIN'.")'
    else
        subdomain_filter='| select(.'$subdomain_key' == "")'
    fi

    filter=$base_filter' | select(.TypeRecord == "'$record_type'") '$subdomain_filter' | .'$attr''
    request '' -XGET | jq -r "$filter"
}

get_record_id () {
    record_type=$1
    subdomain=$2
    get_record_attr "$record_type" "$subdomain" 'ID'
}

get_record_ip () {
    record_type=$1
    subdomain=$2
    get_record_attr "$record_type" "$subdomain" 'IP'
}

get_record_content () {
    record_type=$1
    subdomain=$2
    get_record_attr "$record_type" "$subdomain" 'HostName'
}

delete_record () {
    record_id=$1
    request "$(get_domain_id)/$record_id" -XDELETE
}

add_txt_record () {
    subdomain=$1
    content=$2

    request recordtxt -d '{"DomainId":"'$(get_domain_id)'","Name":"'$subdomain.$DOMAIN'","HostName":"'$subdomain.$DOMAIN'","Text":"'$content'"}'

    STATE=
    while [ "$STATE" != Active ]
    do
        sleep 1
        STATE=$(get_record_attr TXT $subdomain State)
    done
}

check_cname () {
    subdomain=$1
    get_record_attr CNAME $subdomain HostName | grep -qE '^@$'
}

set_cname () {
    subdomain=$1
    current_target=$(get_record_attr CNAME $subdomain HostName)

    if [ "$current_target" != "@" ]
    then
        request recordcname -d '{"DomainId":"'$(get_domain_id)'","Name":"@","MnemonicName":"'$subdomain'"}'
    fi
}

set_record_ip () {
    record_id=$1
    ip=$2

    request recorda/$record_id -XPUT -d '{"DomainId": "'$(get_domain_id)'", "IP": "'$ip'", "Name":"@"}'
}
