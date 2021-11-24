# TP4 : Une distribution orientée serveur

🌞 **Choisissez et définissez une IP à la VM**

```bash
[titi@localhost ~]$ cat /etc/sysconfig/network-scripts/ifcfg-enp0s8
TYPE=Ethernet
BOOTPROTO=static
NAME=enp0s8
DEVICE=enp0s8
ONBOOT=yes
IPADDR=10.250.1.2
NETMASK=255.255.255.0

[titi@localhost ~]$ ip a
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:b1:52:f8 brd ff:ff:ff:ff:ff:ff
    inet 10.250.1.2
```

---

➜ **Connexion SSH fonctionnelle**

🌞 **Vous me prouverez que :**

```bash
[titi@localhost ~]$ systemctl status sshd
● sshd.service - OpenSSH server daemon
   Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
   Active: active (running) since Wed 2021-11-24 04:26:40 EST; 2h 54min ago
```

➜ **Accès internet**

🌞 **Prouvez que vous avez un accès internet**

```bash
[titi@localhost ~]$ ping 1.1.1.1
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=63 time=31.2 ms

```

🌞 **Prouvez que vous avez de la résolution de nom**

```bash
[titi@localhost ~]$ ping -c 3 github.com
PING github.com (140.82.121.4) 56(84) bytes of data.
64 bytes from lb-140-82-121-4-fra.github.com (140.82.121.4): icmp_seq=1 ttl=63 time=33.7 ms
64 bytes from lb-140-82-121-4-fra.github.com (140.82.121.4): icmp_seq=2 ttl=63 time=37.5 ms
64 bytes from lb-140-82-121-4-fra.github.com (140.82.121.4): icmp_seq=3 ttl=63 time=35.6 ms
```

🌞 **Définissez `node1.tp4.linux` comme nom à la machine**

```bash
[titi@node1 ~]$ cat /etc/hostname
node1.tp4.linux
[titi@node1 ~]$ hostname
node1.tp4.linux
```

# III. Mettre en place un service

## 2. Install

🌞 **Installez NGINX en vous référant à des docs online**

```bash
[titi@node1 ~]$ sudo dnf install nginx
[titi@node1 ~]$ sudo systemctl start nginx
[titi@node1 ~]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor pres>
   Active: active (running) since Wed 2021-11-24 08:24:59 EST; 9s ago
```

## 3. Analyse

Avant de config étou, on va lancer à l'aveugle et inspecter ce qu'il se passe.

Commencez donc par démarrer le service NGINX :

```bash
$ sudo systemctl start nginx
$ sudo systemctl status nginx
```

🌞 **Analysez le service NGINX**

```bash
[titi@node1 ~]$ ps -ef | grep nginx
root       27975       1  0 08:24 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx      27976   27975  0 08:24 ?        00:00:00 nginx: worker process
titi       28000    1579  0 08:38 pts/0    00:00:00 grep --color=auto nginx
ss -ntl
State       Recv-Q      Send-Q           Local Address:Port           Peer Address:Port     Process
LISTEN      0           128                    0.0.0.0:22                  0.0.0.0:*
LISTEN      0           128                    0.0.0.0:80                  0.0.0.0:*
LISTEN      0           128                       [::]:22                     [::]:*
LISTEN      0           128                       [::]:80                     [::]:*

server {
	listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  _;
        root         /usr/share/nginx/html;

[titi@node1 nginx]$ ls -l
total 0
drwxr-xr-x. 2 root root  99 Nov 24 08:24 html
drwxr-xr-x. 2 root root 143 Nov 24 08:24 modules

```

## 4. Visite du service web

🌞 **Configurez le firewall pour autoriser le trafic vers le service NGINX** (c'est du TCP ;) )

```bash
[titi@node1 nginx]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
```

🌞 **Tester le bon fonctionnement du service**

```bash
ciremy@ciremy-Aspire-A315-56:~$ curl 10.250.1.2
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
```

## 5. Modif de la conf du serveur web

🌞 **Changer le port d'écoute**

```bash
[titi@node1 ~]$ sudo nano /etc/nginx/nginx.conf
  server {
	listen       8080 default_server;
        listen       [::]:8080 default_server;

[titi@node1 ~]$ sudo systemctl restart nginx
[titi@node1 ~]$ systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2021-11-24 15:48:49 EST; 47s ago

[titi@node1 ~]$ ss -alnpt
State       Recv-Q      Send-Q           Local Address:Port           Peer Address:Port     Process
LISTEN      0           128                    0.0.0.0:8080                0.0.0.0:*
LISTEN      0           128                    0.0.0.0:22                  0.0.0.0:*
LISTEN      0           128                       [::]:8080                   [::]:*
LISTEN      0           128                       [::]:22                     [::]:*
[titi@node1 ~]$ sudo firewall-cmd --remove-port=80/tcp --permanent
[sudo] password for titi:
success
[titi@node1 ~]$ sudo firewall-cmd --add-port=8080/tcp --permanent
success

ciremy@ciremy-Aspire-A315-56:~$ curl 10.250.1.2:8080
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">

```

🌞 **Changer l'utilisateur qui lance le service**

```bash
[titi@node1 ~]$ sudo useradd web -m -s /home/web -u 100
[titi@node1 ~]$ sudo passwd web
Changing password for user web.
New password:
BAD PASSWORD: The password is shorter than 8 characters
Retype new password:
passwd: all authentication tokens updated successfully.

[titi@node1 ~]$ cat /etc/passwd | grep web
web:x:100:1001::/home/web:/home/web

[titi@node1 ~]$ sudo nano /etc/nginx/nginx.conf
user web;

[titi@node1 ~]$ ps -ef | grep web
web         1794    1793  0 16:22 ?        00:00:00 nginx: worker process
```

- pour ça, vous créerez vous-même un nouvel utilisateur sur le système : `web`
  - référez-vous au [mémo des commandes](../../cours/memos/commandes.md) pour la création d'utilisateur
  - l'utilisateur devra avoir un mot de passe, et un homedir défini explicitement à `/home/web`
- un peu de conf à modifier dans le fichier de conf de NGINX pour définir le nouvel utilisateur en tant que celui qui lance le service
  - vous me montrerez la conf effectuée dans le compte-rendu
- n'oubliez pas de redémarrer le service pour que le changement prenne effet
- vous prouverez avec une commande `ps` que le service tourne bien sous ce nouveau utilisateur

---

🌞 **Changer l'emplacement de la racine Web**

```bash
[titi@node1 var]$ sudo mkdir www
[sudo] password for titi:
[titi@node1 var]$ cd www/
[titi@node1 www]$ mkdir mon_site
mkdir: cannot create directory 'mon_site': Permission denied
[titi@node1 www]$ sudo mkdir mon_site
[titi@node1 www]$ nano mon_site/index.html
[titi@node1 www]$ sudo nano mon_site/index.html
<h1>tototititututata<h1>

[titi@node1 www]$ ls -l
total 0
drwxr-xr-x. 2 web root 24 Nov 24 16:36 mon_site
[titi@node1 www]$ cd mon_site/
[titi@node1 mon_site]$ ls -l
total 4
-rw-r--r--. 1 root root 25 Nov 24 16:36 index.html

[titi@node1 mon_site]$ sudo nano /etc/nginx/nginx.conf

        root         /var/www/mon_site;

[titi@node1 mon_site]$ sudo nano /etc/nginx/nginx.conf
[titi@node1 mon_site]$ sudo systemctl restart nginx
ciremy@ciremy-Aspire-A315-56:~$ curl 10.250.1.2:8080
<h1>tototititututata<h1>
```
