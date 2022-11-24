# Reverse Proxy

```bash
[ciremy@localhost ~]$ sudo dnf install nginx
[ciremy@localhost ~]$ sudo systemctl start nginx
[ciremy@localhost ~]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
     Active: active (running) since Tue 2022-11-22 12:34:43 CET; 2s ago
[ciremy@localhost ~]$ ss -al
tcp   LISTEN 0      511                                           [::]:http
[ciremy@localhost ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[ciremy@localhost ~]$ ps -ef
nginx        977     976  0 12:34 ?        00:00:00 nginx: worker process
[ciremy@localhost ~]$ curl 10.102.1.13:80
<!doctype html>
<html>
[ciremy@localhost conf.d]$ sudo nano proxy.conf

[ciremy@tp2 ~]$ sudo nano /var/www/tp2_nextcloud/config/config.php
<?php
$CONFIG = array (
  'instanceid' => 'ocmkigo6m5wv',
  'passwordsalt' => 'DVpRtVYmfUp2WS7sDQry/LR+NRUOlW',
  'secret' => 'nOWLKlADOp6zQeqIutsO0yAciUxKdQaJBg30y4rtvTDDye1o',
  'trusted_domains' =>
  array (
    2 => 'tp2',
    1 => '10.102.1.13',
...
```

```bash
[ciremy@tp2 ~]$ sudo nano /etc/httpd/conf.d/nextcloud.conf
#    Require all granted
#   AllowOverride All
    require ip 10.102.1.13

```

## HTTPS

```bash
[ciremy@tp2 ~]$ sudo mkdir /etc/nginx/certificate

[ciremy@tp2 ~]$ cd /etc/nginx/certificate

[ciremy@tp2 certificate]$ sudo openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out nginx-certificate.crt -keyout nginx.key

[ciremy@tp2 certificate]$ ls
nginx-certificate.crt  nginx.key

[ciremy@localhost certificate]$ sudo nano /etc/nginx/conf.d/proxy.conf
# Port d'écoute de NGINX
    listen 443 ssl;
    ssl_certificate /etc/nginx/certificate/nginx-certificate.crt;
    ssl_certificate_key /etc/nginx/certificate/nginx.key;

[ciremy@localhost certificate]$ sudo firewall-cmd --add-port=443/tcp
success
[ciremy@localhost certificate]$ sudo firewall-cmd --add-port=443/tcp --permanent
success


```

# Monitoring

install:

```bash
[ciremy@localhost ~]$ wget -O /tmp/netdata-kickstart.sh https://my-netdata.io/kickstart.sh && sh /tmp/netdata-kickstart.sh
[ciremy@localhost ~]$ sudo firewall-cmd --permanent --add-port=19999/tcp
success
[ciremy@localhost ~]$ sudo firewall-cmd --reload
success

[ciremy@localhost ~]$ sudo /etc/netdata/edit-config health_alarm_notify.conf

sudo dnf install stress-ng -y
stress -c 8
```
