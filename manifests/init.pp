class yandex_ddns (
    $domain,
    $provider,
    $token,
) {
    $directory = "/opt/yandex_ddns"

    file { $directory:
        ensure => directory,
    }

    file { "$directory/environment":
        ensure  => present,
        content => template('yandex_ddns/environment.erb'),
        mode    => '0600',
        notify  => Service['yandex_ddns'],
    }

    file { "$directory/update":
        ensure  => present,
        mode    => '0755',
        content => file('yandex_ddns/update'),
        notify  => Service['yandex_ddns'],
    }

    file { "$directory/functions.sh":
      ensure  => present,
      mode    => '0755',
      content => file("yandex_ddns/functions.$provider.sh"),
    }

    file { "$directory/authenticator.sh":
      ensure  => present,
      mode    => '0755',
      content => file('yandex_ddns/authenticator.sh'),
    }

    file { "$directory/cleanup.sh":
      ensure  => present,
      mode    => '0755',
      content => file('yandex_ddns/cleanup.sh'),
    }

    file { "/etc/systemd/system/yandex_ddns.service":
        ensure  => file,
        content => file('yandex_ddns/yandex_ddns.service'),
        notify  => Service['yandex_ddns'],
    }

    file { "/etc/systemd/system/yandex_ddns.timer":
        ensure  => file,
        content => file('yandex_ddns/yandex_ddns.timer'),
        notify  => Service['yandex_ddns'],
    }

    service { 'yandex_ddns':
        provider => systemd,
    }

    service { "yandex_ddns.timer":
        ensure   => running,
        provider => systemd,
        enable   => true,
    }

    package { 'jq':
        ensure => latest,
    }

    file { "$directory/cname":
        ensure  => present,
        mode    => '0755',
        content => file('yandex_ddns/cname'),
    }
}
