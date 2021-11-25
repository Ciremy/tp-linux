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

> Il existe des tonnes de guides sur internet pour expliquer ce que fait cette commande et comment répondre aux questions, afin d'augmenter le niveau de sécurité de la base.

---

🌞 **Préparation de la base en vue de l'utilisation par NextCloud**

- pour ça, il faut vous connecter à la base
- il existe un utilisateur `root` dans la base de données, qui a tous les droits sur la base
- si vous avez correctement répondu aux questions de `mysql_secure_installation`, vous ne pouvez utiliser le user `root` de la base de données qu'en vous connectant localement à la base
- donc, sur la VM `db.tp5.linux` toujours :

```bash
# Connexion à la base de données
# L'option -p indique que vous allez saisir un mot de passe
# Vous l'avez défini dans le mysql_secure_installation
$ sudo mysql -u root -p
```

Puis, dans l'invite de commande SQL :

```sql
# Création d'un utilisateur dans la base, avec un mot de passe
# L'adresse IP correspond à l'adresse IP depuis laquelle viendra les connexions. Cela permet de restreindre les IPs autorisées à se connecter.
# Dans notre cas, c'est l'IP de web.tp5.linux
# "meow" c'est le mot de passe :D
CREATE USER 'nextcloud'@'10.5.1.11' IDENTIFIED BY 'meow';

# Création de la base de donnée qui sera utilisée par NextCloud
CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

# On donne tous les droits à l'utilisateur nextcloud sur toutes les tables de la base qu'on vient de créer
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'10.5.1.11';

# Actualisation des privilèges
FLUSH PRIVILEGES;
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

- vous utiliserez la commande `dnf provides` pour trouver dans quel paquet se trouve cette commande

🌞 **Tester la connexion**

- utilisez la commande `mysql` depuis `web.tp5.linux` pour vous connecter à la base qui tourne sur `db.tp5.linux`
- vous devrez préciser une option pour chacun des points suivants :
  - l'adresse IP de la machine où vous voulez vous connectez `db.tp5.linux` : `10.5.1.12`
  - le port auquel vous vous connectez
  - l'utilisateur de la base de données sur lequel vous connecter : `nextcloud`
  - l'option `-p` pour indiquer que vous préciserez un password
    - vous ne devez PAS le préciser sur la ligne de commande
    - sinon il y aurait un mot de passe en clair dans votre historique, c'est moche
  - la base de données à laquelle vous vous connectez : `nextcloud`
- une fois connecté à la base en tant que l'utilisateur `nextcloud` :
  - effectuez un bête `SHOW TABLES;`
  - simplement pour vous assurer que vous avez les droits de lecture
  - et constater que la base est actuellement vide

> Je veux donc dans le compte-rendu la commande `mysql` qui permet de se co depuis `web.tp5.linux` au service de base de données qui tourne sur `db.tp5.linux`, ainsi que le `SHOW TABLES`.

---

C'est bon ? Ca tourne ? [**Go installer NextCloud maintenant !**](./web.md)

![To the cloud](./pics/to_the_cloud.jpeg)

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

```

- lancez le service `httpd` et activez le au démarrage
- isolez les processus liés au service `httpd`
- déterminez sur quel port écoute Apache par défaut
- déterminez sous quel utilisateur sont lancés les processus Apache

---

🌞 **Un premier test**

- ouvrez le port d'Apache dans le firewall
- testez, depuis votre PC, que vous pouvez accéder à la page d'accueil par défaut d'Apache
  - avec une commande `curl`
  - avec votre navigateur Web

### B. PHP

NextCloud a besoin d'une version bien spécifique de PHP.  
Suivez **scrupuleusement** les instructions qui suivent pour l'installer.

🌞 **Installer PHP**

```bash
# ajout des dépôts EPEL
$ sudo dnf install epel-release
$ sudo dnf update
# ajout des dépôts REMI
$ sudo dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
$ dnf module enable php:remi-7.4

# install de PHP et de toutes les libs PHP requises par NextCloud
$ sudo dnf install zip unzip libxml2 openssl php74-php php74-php-ctype php74-php-curl php74-php-gd php74-php-iconv php74-php-json php74-php-libxml php74-php-mbstring php74-php-openssl php74-php-posix php74-php-session php74-php-xml php74-php-zip php74-php-zlib php74-php-pdo php74-php-mysqlnd php74-php-intl php74-php-bcmath php74-php-gmp
```

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

🌞 **Créer un VirtualHost qui accueillera NextCloud**

- créez un nouveau fichier dans le dossier de _drop-in_
  - attention, il devra être correctement nommé (l'extension) pour être inclus par le fichier de conf principal
- ce fichier devra avoir le contenu suivant :

```apache
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
```

> N'oubliez pas de redémarrer le service à chaque changement de la configuration, pour que les changements prennent effet.

🌞 **Configurer la racine web**

- la racine Web, on l'a configurée dans Apache pour être le dossier `/var/www/nextcloud/html/`
- creéz ce dossier
- faites appartenir le dossier et son contenu à l'utilisateur qui lance Apache (commande `chown`, voir le [mémo commandes](../../cours/memos/commandes.md))

> Jusqu'à la fin du TP, tout le contenu de ce dossier doit appartenir à l'utilisateur qui lance Apache. C'est strictement nécessaire pour qu'Apache puisse lire le contenu, et le servir aux clients.

🌞 **Configurer PHP**

- dans l'install de NextCloud, PHP a besoin de conaître votre timezone (fuseau horaire)
- pour récupérer la timezone actuelle de la machine, utilisez la commande `timedatectl` (sans argument)
- modifiez le fichier `/etc/opt/remi/php74/php.ini` :
  - changez la ligne `;date.timezone =`
  - par `date.timezone = "<VOTRE_TIMEZONE>"`
  - par exemple `date.timezone = "Europe/Paris"`

## 3. Install NextCloud

On dit "installer NextCloud" mais en fait c'est juste récupérer les fichiers PHP, HTML, JS, etc... qui constituent NextCloud, et les mettre dans le dossier de la racine web.

🌞 **Récupérer Nextcloud**

```bash
# Petit tips : la commande cd sans argument permet de retourner dans votre homedir
$ cd

# La commande curl -SLO permet de rapidement télécharger un fichier, en HTTP/HTTPS, dans le dossier courant
$ curl -SLO https://download.nextcloud.com/server/releases/nextcloud-21.0.1.zip

$ ls
nextcloud-21.0.1.zip
```

🌞 **Ranger la chambre**

- extraire le contenu de NextCloud (beh ui on a récup un `.zip`)
- déplacer tout le contenu dans la racine Web
  - n'oubliez pas de gérer les permissions de tous les fichiers déplacés ;)
- supprimer l'archive

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

---

🌞 **Modifiez le fichier `hosts` de votre PC**

- ajoutez la ligne : `10.5.1.11 web.tp5.linux`

🌞 **Tester l'accès à NextCloud et finaliser son install'**

- ouvrez votre navigateur Web sur votre PC
- rdv à l'URL `http://web.tp5.linux`
- vous devriez avoir la page d'accueil de NextCloud
- ici deux choses :
  - les deux champs en haut pour créer un user admin au sein de NextCloud
  - le bouton "Configure the database" en bas
    - sélectionnez "MySQL/MariaDB"
    - entrez les infos pour que NextCloud sache comment se connecter à votre serveur de base de données
    - c'est les infos avec lesquelles vous avez validé à la main le bon fonctionnement de MariaDB (c'était avec la commande `mysql`)

---

**🔥🔥🔥 Baboom ! Un beau NextCloud.**

Naviguez un peu, faites vous plais', vous avez votre propre DropBox n_n

![Well Done](./pics/well_done.jpg)
