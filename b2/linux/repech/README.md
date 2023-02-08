# TP Repeche linux

## Install emby et mise en évidence du service

```bash
Installed:
  emby-server-4.7.11.0-1.x86_64
[ciremy@web ~]$ systemctl status emby-server
● emby-server.service - Emby Server is a personal media server with apps on just about every device
     Loaded: loaded (/usr/lib/systemd/system/emby-server.service; enabled; vendor preset: disabled)
     Active: active (running) since Sat 2023-02-04 17:50:07 CET; 2min 18s ago
[ciremy@web ~]$ ps -ef | grep emby
emby        1010       1  1 17:50 ?        00:00:03 /opt/emby-server/system/EmbyServer -programdata /var/lib/emby -ffdetect /opt/emby-server/bin/ffdetect -ffmpeg /opt/emby-server/bin/ffmpeg -ffprobe /opt/emby-server/bin/ffprobe -restartexitcode 3 -updatepackage emby-server-rpm_{version}_x86_64.rpm
[ciremy@web ~]$ ss -al | grep 8096
tcp   LISTEN 0      512                                             *:8096                          *:*
```

## Ouverture des ports

```bash
[ciremy@web ~]$ sudo firewall-cmd --zone=public --add-port=8096/tcp
success
```

🌞 **Configurer un répertoire pour accueillir vos médias**

```bash
[ciremy@web srv]$ ls -l
total 0
drwxrw-rw-. 2 emby root 36 Feb  4 19:00 media
```

# 2. Reverse proxy

## A. Setup

> A faire sur 🖥️ `proxy.peche.linux`.

Ici, on mettre en place un reverse proxy qui protégera l'accès à notre serveur Web.

## Mise en place de nginx

```bash
[ciremy@proxy ~]$ sudo nano /etc/nginx/nginx.conf
server {

    server_name web;
    listen 80;
    listen 443 ssl;
    ssl_certificate /etc/nginx/certificate/nginx-certificate.crt;
    ssl_certificate_key /etc/nginx/certificate/nginx.key;


    location / {
        proxy_set_header  Host $host;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-Proto https;
        proxy_set_header  X-Forwarded-Host $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;

        # On définit la cible du proxying
        proxy_pass http://10.102.1.10:8096;
    }

    # Deux sections location recommandés par la doc NextCloud
    location /.well-known/carddav {
      return 301 $scheme://$host/remote.php/dav;
    }

    location /.well-known/caldav {
      return 301 $scheme://$host/remote.php/dav;
    }
}
[ciremy@web ~]$ sudo firewall-cmd --zone=public --permanent --remove-port 80

```

# 3. Backup

### A. Serveur NFS

```bash
[ciremy@backup music]$ sudo useradd backup
[ciremy@backup /]$ sudo chown backup /backup/music/
[ciremy@backup ~]$ sudo nano /etc/exports
[ciremy@backup ~]$ sudo cat /etc/exports
/backup/music/ 10.102.1.10(rw,sync,no_subtree_check)

[ciremy@backup ~]$ sudo systemctl enable nfs-server
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.
[ciremy@backup ~]$ sudo systemctl start nfs-server
[ciremy@backup ~]$ systemctl status nfs-server
● nfs-server.service - NFS server and services
     Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled;
[ciremy@backup ~]$ sudo firewall-cmd --add-service=nfs --permanent
success
[ciremy@backup ~]$ sudo firewall-cmd --add-service=mountd --permanent
success
[ciremy@backup ~]$ sudo firewall-cmd --add-service=rpc-bind --permanent
success
[ciremy@backup ~]$ sudo firewall-cmd --reload
success
```

### B. Client NFS

> A faire sur 🖥️ `web.peche.linux`.

## Client nfs

```
[ciremy@web ~]$ sudo mount 10.102.1.11:/backup/music /backup
```

## Script de backup

Malheureusement je n'ai pas réussi à faire le script

## Timer

```
[ciremy@web ~]$ sudo cat /etc/systemd/system/backup.timer
[Unit]
Description=Run service backup

[Timer]
OnCalendar=*-*-* 4:00:00
Persistent=true

[Install]
WantedBy=timers.target
```
