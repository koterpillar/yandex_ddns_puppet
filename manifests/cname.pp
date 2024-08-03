define yandex_ddns::cname {
    exec { "/opt/yandex_ddns/cname set $name":
        unless => "/opt/yandex_ddns/cname check $name",
    }
}
