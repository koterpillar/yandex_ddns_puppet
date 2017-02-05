define yandex_ddns::cname {
    exec { "/opt/yandex_ddns/update-cname $name":
    }
}
