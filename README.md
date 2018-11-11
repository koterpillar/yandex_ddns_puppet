# Puppet module to manage Yandex domain records (pdd.yandex.ru)

This module ensures the A record points to the server's current IP, and points
CNAME records back to it.

It requires an [API token](https://pddimp.yandex.ru/api2/admin/get_token).

## Usage

```puppet

# Point example.com to the current server's IP address

class { 'yandex_ddns':
  domain    => 'example.com',
  token     => '123456789ABCDEF0000000000000000000000000000000000000',
}

# Make www.example.com a CNAME for example.com

yandex_ddns::cname { 'www':
}
```

## Certbot authenticator

When a `yandex_ddns` is provisioned, an `/opt/yandex_ddns/authenticator.sh` and
`/opt/yandex_ddns/cleanup.sh` are provided for Certbot authenticator.
