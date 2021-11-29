# I. Setup DB

## Sommaire

- [I. Setup DB](#i-setup-db)
  - [Sommaire](#sommaire)
  - [1. Install MariaDB](#1-install-mariadb)
  - [2. Conf MariaDB](#2-conf-mariadb)
  - [3. Test](#3-test)

## 1. Install MariaDB

> Pour rappel, le gestionnaire de paquets sous les OS de la famille RedHat, c'est pas `apt`, c'est `dnf`.

🌞 **Installer MariaDB sur la machine `db.tp5.linux`**

```bash
[titi@db ~]$ sudo dnf install mariadb-server
[sudo] password for titi:
Failed to set locale, defaulting to C.UTF-8
Last metadata expiration check: 2:51:14 ago on Thu Nov 25 08:17:22 2021.
Dependencies resolved.
```

🌞 **Le service MariaDB**

```bash
[titi@db ~]$ systemctl start mariadb.service
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ====
Authentication is required to start 'mariadb.service'.

[titi@db ~]$ sudo systemctl enable mariadb
[sudo] password for titi:
Created symlink /etc/systemd/system/mysql.service → /usr/lib/systemd/system/mariadb.service.

[titi@db ~]$ systemctl status mariadb
● mariadb.service - MariaDB 10.3 database server
   Loaded: loaded (/usr/lib/systemd/system/mariadb.service; enabled; vendor preset: disabled)
   Active: active (running) since Thu 2021-11-25 11:14:24 EST; 2min 4s ago

ss -alnpt
State       Recv-Q      Send-Q           Local Address:Port           Peer Address:Port     Process
LISTEN      0           80                           *:3306                      *:*

[titi@db ~]$ ps -ef | grep mariadb
titi       28580    1503  0 11:21 pts/0    00:00:00 grep --color=auto mariadb

```

🌞 **Firewall**

```bash
[titi@db ~]$ sudo firewall-cmd --add-port=3306/tcp --permanent
[titi@db ~]$ sudo firewall-cmd --reload
success
```

## 2. Conf MariaDB

🌞 **Configuration élémentaire de la base**

```bash
Set root password? [Y/n] Y
#pour sécurisé les connexions non voulu

Remove anonymous users? [Y/n] Y
#pour empecher les connexions anonymes

Disallow root login remotely? [Y/n] y
#pour eviter les connexions distante de root

Remove test database and access to it? [Y/n] Y
#supprime la table de test qui est inutile

Reload privilege tables now? [Y/n] y
#rend effectif tout les changements
```

🌞 **Préparation de la base en vue de l'utilisation par NextCloud**

```bash
[titi@db ~]$ sudo mysql -u root -p
[sudo] password for titi:
Enter password:

```

Puis, dans l'invite de commande SQL :

```sql
MariaDB [(none)]> CREATE USER 'nextcloud'@'10.5.1.11' IDENTIFIED BY 'meow';
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
Query OK, 1 row affected (0.001 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'10.5.1.11';
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.001 sec)
```

## 3. Test

Bon, là il faut tester que la base sera utilisable par NextCloud.

Concrètement il va faire quoi NextCloud vis-à-vis de la base MariaDB ?

- se connecter sur le port où écoute MariaDB
- la connexion viendra de `web.tp5.linux`
- il se connectera en utilisant l'utilisateur `nextcloud`
- il écrira/lira des données dans la base `nextcloud`

Il faudrait donc qu'on teste ça, à la main, depuis la machine `web.tp5.linux`.

Bah c'est parti ! Il nous faut juste un client pour nous connecter à la base depuis la ligne du commande : il existe une commande `mysql` pour ça.

🌞 **Installez sur la machine `web.tp5.linux` la commande `mysql`**

```bash
[titi@web ~]$ sudo dnf install mysql
[sudo] password for titi:
Failed to set locale, defaulting to C.UTF-8
Last metadata expiration check: 1:53:24 ago on Thu Nov 25 10:55:22 2021.
Dependencies resolved.
```

🌞 **Tester la connexion**

```bash
[titi@web ~]$ sudo mysql -u nextcloud -p -P 3306 -D nextcloud -h 10.5.1.12
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 18
Server version: 5.5.5-10.3.28-MariaDB MariaDB Server

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> SHOW TABLES;
Empty set (0.00 sec)
```

# II. Setup Web

## Sommaire

- [II. Setup Web](#ii-setup-web)
  - [Sommaire](#sommaire)
  - [1. Install Apache](#1-install-apache)
    - [A. Apache](#a-apache)
    - [B. PHP](#b-php)
  - [2. Conf Apache](#2-conf-apache)
  - [3. Install NextCloud](#3-install-nextcloud)
  - [4. Test](#4-test)

## 1. Install Apache

### A. Apache

🌞 **Installer Apache sur la machine `db.tp5.linux`**

```bash
[titi@web ~]$ sudo dnf install httpd
Failed to set locale, defaulting to C.UTF-8
Last metadata expiration check: 2:27:08 ago on Thu Nov 25 08:17:22 2021.
Dependencies resolved.
```

🌞 **Analyse du service Apache**

```bash
[titi@web ~]$ systemctl start httpd
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ====
Authentication is required to start 'httpd.service'.
Authenticating as: titi
Password:
==== AUTHENTICATION COMPLETE ====
[titi@web ~]$ systemctl enable httpd
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-unit-files ====
Authentication is required to manage system service or unit files.
Authenticating as: titi
Password:
==== AUTHENTICATION COMPLETE ====
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
==== AUTHENTICATING FOR org.freedesktop.systemd1.reload-daemon ====
Authentication is required to reload the systemd state.
Authenticating as: titi
Password:
==== AUTHENTICATION COMPLETE ====

[titi@web ~]$ ps -ef | grep httpd
root       27028       1  0 13:00 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache     27029   27028  0 13:00 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache     27030   27028  0 13:00 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache     27031   27028  0 13:00 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache     27032   27028  0 13:00 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
titi       27304    1566  0 13:01 pts/0    00:00:00 grep --color=auto httpd

[titi@web ~]$ sudo ss -altnp
LISTEN       0             128                              *:80                            *:*           users:(("httpd",pid=27032,fd=4),("httpd",pid=27031,fd=4),("httpd",pid=27030,fd=4),("httpd",pid=27028,fd=4))
```

🌞 **Un premier test**

```bash
[titi@web ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success

[titi@web ~]$ sudo firewall-cmd --reload
success

curl 10.5.1.11
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>

```

### B. PHP

🌞 **Installer PHP**

```bash
[titi@web ~]$ sudo dnf install epel-release
...
Installed:
  epel-release-8-13.el8.noarch

[titi@web ~]$ sudo dnf update
Nothing to do.
Complete!

[titi@web ~]$ sudo dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
...
Installed:
  remi-release-8.5-1.el8.remi.noarch

[titi@web ~]$ dnf module enable php:remi-7.4

Complete!

[titi@web ~]$ sudo dnf install zip unzip libxml2 openssl php74-php php74-php-ctype php74-php-curl php74-php-gd php74-php-iconv php74-php-json php74-php-libxml php74-php-mbstring php74-php-openssl php74-php-posix php74-php-session php74-php-xml php74-php-zip php74-php-zlib php74-php-pdo php74-php-mysqlnd php74-php-intl php74-php-bcmath php74-php-gmp

Installed:
  environment-modules-4.5.2-1.el8.x86_64              gd-2.2.5-7.el8.x86_64
  jbigkit-libs-2.1-14.el8.x86_64                      libXpm-3.5.12-8.el8.x86_64
  libicu69-69.1-1.el8.remi.x86_64                     libjpeg-turbo-1.5.3-12.el8.x86_64
  libsodium-1.0.18-2.el8.x86_64                       libtiff-4.0.9-20.el8.x86_64
  libwebp-1.0.0-5.el8.x86_64                          oniguruma5php-6.9.7.1-1.el8.remi.x86_64
  php74-libzip-1.8.0-1.el8.remi.x86_64                php74-php-7.4.26-1.el8.remi.x86_64
  php74-php-bcmath-7.4.26-1.el8.remi.x86_64           php74-php-cli-7.4.26-1.el8.remi.x86_64
  php74-php-common-7.4.26-1.el8.remi.x86_64           php74-php-fpm-7.4.26-1.el8.remi.x86_64
  php74-php-gd-7.4.26-1.el8.remi.x86_64               php74-php-gmp-7.4.26-1.el8.remi.x86_64
  php74-php-intl-7.4.26-1.el8.remi.x86_64             php74-php-json-7.4.26-1.el8.remi.x86_64
  php74-php-mbstring-7.4.26-1.el8.remi.x86_64         php74-php-mysqlnd-7.4.26-1.el8.remi.x86_64
  php74-php-opcache-7.4.26-1.el8.remi.x86_64          php74-php-pdo-7.4.26-1.el8.remi.x86_64
  php74-php-pecl-zip-1.20.0-1.el8.remi.x86_64         php74-php-process-7.4.26-1.el8.remi.x86_64
  php74-php-sodium-7.4.26-1.el8.remi.x86_64           php74-php-xml-7.4.26-1.el8.remi.x86_64
  php74-runtime-1.0-3.el8.remi.x86_64                 scl-utils-1:2.0.2-14.el8.x86_64
  tcl-1:8.6.8-2.el8.x86_64
```

NextCloud a besoin d'une version bien spécifique de PHP.  
Suivez **scrupuleusement** les instructions qui suivent pour l'installer.

## 2. Conf Apache

➜ Le fichier de conf utilisé par Apache est `/etc/httpd/conf/httpd.conf`.  
Il y en a plein d'autres : ils sont inclus par le premier.

➜ Dans Apache, il existe la notion de _VirtualHost_. On définit des _VirtualHost_ dans les fichiers de conf d'Apache.  
On crée un _VirtualHost_ pour chaque application web qu'héberge Apache.

> "Application Web" c'est le terme de hipster pour désigner un site web. Disons qu'aujourd'hui les sites peuvent faire tellement de trucs qu'on appelle plutôt ça une "application" à part entière. Une application web donc.

➜ Dans le dossier `/etc/httpd/` se trouve un dossier `conf.d`.  
Des dossiers qui se terminent par `.d`, vous en rencontrerez plein, ce sont des dossiers de _drop-in_.  
Plutôt que d'écrire 40000 lignes dans un seul fichier de conf, on l'éclate en plusieurs fichiers la conf.  
C'est + lisible et + facilement maintenable.

Les dossiers de _drop-in_ servent à accueillir ces fichiers de conf additionels.  
Le fichier de conf principal a une ligne qui inclut tous les fichiers de conf contenus dans le dossier de _drop-in_.

---

🌞 **Analyser la conf Apache**

- mettez en évidence, dans le fichier de conf principal d'Apache, la ligne qui inclut tout ce qu'il y a dans le dossier de _drop-in_

```bash
[titi@web ~]$ sudo cat /etc/httpd/conf/httpd.conf | grep conf.d
IncludeOptional conf.d/*.conf
```

🌞 **Créer un VirtualHost qui accueillera NextCloud**

```bash
[titi@web ~]$ cat /etc/httpd/conf.d/virtualhost.conf
<VirtualHost *:80>
  DocumentRoot /var/www/nextcloud/html/  # on précise ici le dossier qui contiendra le site : la racine Web
  ServerName  web.tp5.linux  # ici le nom qui sera utilisé pour accéder à l'application

  <Directory /var/www/nextcloud/html/>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews

    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>

[titi@web ~]$ systemctl restart httpd

```

🌞 **Configurer la racine web**

```bash
[titi@web ~]$ sudo mkdir /var/www/nextcloud
[titi@web ~]$ sudo mkdir /var/www/nextcloud/html/

[titi@web www]$ sudo chown apache nextcloud
[titi@web www]$ sudo chown apache nextcloud/html/
```

🌞 **Configurer PHP**

```bash
[titi@web www]$ cat /etc/opt/remi/php74/php.ini | grep date.timezone
date.timezone = "America/New_York"
#(j'ai miss l'install je suis à l'heure de NY ps: pardon)
```

## 3. Install NextCloud

On dit "installer NextCloud" mais en fait c'est juste récupérer les fichiers PHP, HTML, JS, etc... qui constituent NextCloud, et les mettre dans le dossier de la racine web.

🌞 **Récupérer Nextcloud**

```bash
[titi@web ~]$ curl -SLO https://download.nextcloud.com/server/releases/nextcloud-21.0.1.zip
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  148M  100  148M    0     0  3086k      0  0:00:49  0:00:49 --:--:-- 3500k
[titi@web ~]$ ls
nextcloud-21.0.1.zip
```

🌞 **Ranger la chambre**

```bash
[titi@web html]$ sudo unzip nextcloud-21.0.1.zip -d /var/www/nextcloud/html/

[titi@web html]$ ls
nextcloud
[titi@web html]$ mv nextcloud/ /var/www/nextcloud/
mv: cannot move 'nextcloud/' to '/var/www/nextcloud/nextcloud': Permission denied
[titi@web html]$ sudo mv nextcloud/ /var/www/nextcloud/
[titi@web html]$ cd ..
[titi@web nextcloud]$ ls
html  nextcloud
[titi@web nextcloud]$ sudo rm html/
rm: cannot remove 'html/': Is a directory
[titi@web nextcloud]$ sudo rm -d  html/
[titi@web nextcloud]$ ls
nextcloud
[titi@web nextcloud]$ mv nextcloud html
mv: cannot move 'nextcloud' to 'html': Permission denied
[titi@web nextcloud]$ sudo mv nextcloud html
[titi@web nextcloud]$ ls
html
[titi@web nextcloud]$ cd html/

[titi@web ~]$ rm nextcloud-21.0.1.zip

[titi@web www]$ sudo chown apache -R nextcloud/

```

## 4. Test

Bah on arrive sur la fin !

Si on résume :

- **un serveur de base de données : `db.tp5.linux`**
  - MariaDB installé et fonctionnel
  - firewall configuré
  - une base de données et un user pour NextCloud ont été créés dans MariaDB
- **un serveur Web : `web.tp5.linux`**
  - Apache installé et fonctionnel
  - firewall configuré
  - un VirtualHost qui pointe vers la racine `/var/www/nextcloud/html/`
  - NextCloud installé dans le dossier `/var/www/nextcloud/html/`

**Looks like we're ready.**

---

**Ouuu presque. Pour que NextCloud fonctionne correctement, il faut y accéder en utilisant un nom, et pas une IP.**  
On va donc devoir faire en sorte que, depuis votre PC, vous puissiez écrire `http://web.tp5.linux` plutôt que `http://10.5.1.11`.

➜ Pour faire ça, on va utiliser **le fichier `hosts`**. C'est un fichier présents sur toutes les machines, sur tous les OS.  
Il sert à définir, localement, une correspondance entre une IP et un ou plusieurs noms.

C'est arbitraire, on fait ce qu'on veut.  
Si on veut que `www.ynov.com` pointe vers le site de notre VM, ou vers n'importe quelle autre IP, on peut.  
ON PEUT TOUT FAIRE JE TE DIS.  
Ce sera évidemment valable uniquement sur la machine où se trouve le fichier.

Emplacement du fichier `hosts` :

- MacOS/Linux : `/etc/hosts`
- Windows : `c:\windows\system32\drivers\etc\hosts`
