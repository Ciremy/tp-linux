# TP2 : Gestion de service

# Sommaire

- [TP2 : Gestion de service](#tp2--gestion-de-service)
- [Sommaire](#sommaire)
- [0. Prérequis](#0-prérequis)
  - [Checklist](#checklist)
- [I. Un premier serveur web](#i-un-premier-serveur-web)
  - [1. Installation](#1-installation)
  - [2. Avancer vers la maîtrise du service](#2-avancer-vers-la-maîtrise-du-service)
- [II. Une stack web plus avancée](#ii-une-stack-web-plus-avancée)
  - [1. Intro blabla](#1-intro-blabla)
  - [2. Setup](#2-setup)
    - [A. Base de données](#a-base-de-données)
    - [B. Serveur Web et NextCloud](#b-serveur-web-et-nextcloud)
    - [C. Finaliser l'installation de NextCloud](#c-finaliser-linstallation-de-nextcloud)

# 0. Prérequis

➜ Machines Rocky Linux

➜ Un unique host-only côté VBox, ça suffira. **L'adresse du réseau host-only sera `10.102.1.0/24`.**

➜ Chaque **création de machines** sera indiquée par **l'emoji 🖥️ suivi du nom de la machine**

➜ Si je veux **un fichier dans le rendu**, il y aura l'**emoji 📁 avec le nom du fichier voulu**. Le fichier devra être livré tel quel dans le dépôt git, ou dans le corps du rendu Markdown si c'est lisible et correctement formaté.

## Checklist

A chaque machine déployée, vous **DEVREZ** vérifier la 📝**checklist**📝 :

- [x] IP locale, statique ou dynamique
- [x] hostname défini
- [x] firewall actif, qui ne laisse passer que le strict nécessaire
- [x] SSH fonctionnel avec un échange de clé
- [x] accès Internet (une route par défaut, une carte NAT c'est très bien)
- [x] résolution de nom
- [x] SELinux désactivé (vérifiez avec `sestatus`, voir [mémo install VM tout en bas](https://gitlab.com/it4lik/b2-reseau-2022/-/blob/main/cours/memo/install_vm.md#4-pr%C3%A9parer-la-vm-au-clonage))

**Les éléments de la 📝checklist📝 sont STRICTEMENT OBLIGATOIRES à réaliser mais ne doivent PAS figurer dans le rendu.**

![Checklist](./pics/checklist_is_here.jpg)

# I. Un premier serveur web

## 1. Installation

🖥️ **VM web.tp2.linux**

| Machine         | IP            | Service     |
| --------------- | ------------- | ----------- |
| `web.tp2.linux` | `10.102.1.11` | Serveur Web |

🌞 **Installer le serveur Apache**

- paquet `httpd`
- la conf se trouve dans `/etc/httpd/`
  - le fichier de conf principal est `/etc/httpd/conf/httpd.conf`
  - je vous conseille **vivement** de virer tous les commentaire du fichier, à défaut de les lire, vous y verrez plus clair
    - avec `vim` vous pouvez tout virer avec `:g/^ *#.*/d`

```bash
[ciremy@tp2 ~]$ sudo dnf install httpd
```

> Ce que j'entends au-dessus par "fichier de conf principal" c'est que c'est **LE SEUL** fichier de conf lu par Apache quand il démarre. C'est souvent comme ça : un service ne lit qu'un unique fichier de conf pour démarrer. Cherchez pas, on va toujours au plus simple. Un seul fichier, c'est simple.  
> **En revanche** ce serait le bordel si on mettait toute la conf dans un seul fichier pour pas mal de services.  
> Donc, le principe, c'est que ce "fichier de conf principal" définit généralement deux choses. D'une part la conf globale. D'autre part, il inclut d'autres fichiers de confs plus spécifiques.  
> On a le meilleur des deux mondes : simplicité (un seul fichier lu au démarrage) et la propreté (éclater la conf dans plusieurs fichiers).

🌞 **Démarrer le service Apache**

- le service s'appelle `httpd` (raccourci pour `httpd.service` en réalité)
  - démarrez le
  - faites en sorte qu'Apache démarre automatique au démarrage de la machine
  - ouvrez le port firewall nécessaire
    - utiliser une commande `ss` pour savoir sur quel port tourne actuellement Apache
    - une portion du mémo commandes est dédiée à `ss`

```bash
[ciremy@tp2 ~]$ sudo systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)
     Active: active (running) since Tue 2022-11-15 12:55:40 CET; 17s ago
[ciremy@tp2 ~]$ sudo systemctl enable httpd
[sudo] password for ciremy:
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
[ciremy@tp2 ~]$ sudo systemctl enable httpd
[sudo] password for ciremy:
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.

...
```

🌞 **TEST**

```bash
[ciremy@tp2 ~]$ systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
     Active: active (running) since Tue 2022-11-15 14:05:38 CET; 27min ago
[ciremy@tp2 ~]$ curl localhost
<!doctype html>
<html>
ciremy@ciremy-Aspire-A315-56:~$ curl 10.102.1.11
<!doctype html>
<html>

```

## 2. Avancer vers la maîtrise du service

🌞 **Le service Apache...**

```bash
[ciremy@tp2 ~]$ cat /usr/lib/systemd/system/httpd.service
[Unit]
Description=The Apache HTTP Server
Wants=httpd-init.service
After=network.target remote-fs.target nss-lookup.target httpd-init.service
Documentation=man:httpd.service(8)

[Service]
Type=notify
Environment=LANG=C

ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
# Send SIGWINCH for graceful stop
KillSignal=SIGWINCH
KillMode=mixed
PrivateTmp=true
OOMPolicy=continue


```

🌞 **Déterminer sous quel utilisateur tourne le processus Apache**

- mettez en évidence la ligne dans le fichier de conf principal d'Apache (`httpd.conf`) qui définit quel user est utilisé
- utilisez la commande `ps -ef` pour visualiser les processus en cours d'exécution et confirmer que apache tourne bien sous l'utilisateur mentionné dans le fichier de conf
- la page d'accueil d'Apache se trouve dans `/usr/share/testpage/`
  - vérifiez avec un `ls -al` que tout son contenu est **accessible en lecture** à l'utilisateur mentionné dans le fichier de conf

```bash
[ciremy@tp2 ~]$ cat /etc/httpd/conf/httpd.conf
User apache
Group apache
[ciremy@tp2 ~]$ ps -ef
apache     11654   11653  0 14:05 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache     11655   11653  0 14:05 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache     11656   11653  0 14:05 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache     11657   11653  0 14:05 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND

[ciremy@tp2 ~]$ ls -al /usr/share/testpage/
total 12
drwxr-xr-x.  2 root root   24 Nov 15 12:50 .
drwxr-xr-x. 82 root root 4096 Nov 15 12:50 ..
-rw-r--r--.  1 root root 7620 Jul  6 04:37 index.html

```

🌞 **Changer l'utilisateur utilisé par Apache**

```bash
[ciremy@tp2 ~]$ sudo useradd web -m

[ciremy@tp2 ~]$ sudo systemctl restart httpd
[ciremy@tp2 ~]$ systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
     Active: active (running) since Tue 2022-11-15 10:56:03 CET; 6s ago
       Docs: man:httpd.service(8)
   Main PID: 1803 (httpd)
     Status: "Started, listening on: port 80"
      Tasks: 213 (limit: 5906)
     Memory: 22.7M
        CPU: 51ms
     CGroup: /system.slice/httpd.service
             ├─1803 /usr/sbin/httpd -DFOREGROUND
             ├─1804 /usr/sbin/httpd -DFOREGROUND
             ├─1805 /usr/sbin/httpd -DFOREGROUND
             ├─1806 /usr/sbin/httpd -DFOREGROUND
             └─1807 /usr/sbin/httpd -DFOREGROUND

Nov 15 10:56:02 web.tp2.linux systemd[1]: Starting The Apache HTTP Server...
Nov 15 10:56:03 web.tp2.linux systemd[1]: Started The Apache HTTP Server.
Nov 15 10:56:03 web.tp2.linux httpd[1803]: Server configured, listening on: port 80
[ciremy@tp2 ~]$ ps -ef | grep httpd
root        1803       1  0 10:56 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
web         1804    1803  0 10:56 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
web         1805    1803  0 10:56 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
web         1806    1803  0 10:56 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
web         1807    1803  0 10:56 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND

```

🌞 **Faites en sorte que Apache tourne sur un autre port**

```bash
[ciremy@tp2 ~]$ sudo cat /etc/httpd/conf/httpd.conf | grep Listen
Listen 8080
[ciremy@tp2 ~]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
[ciremy@tp2 ~]$ sudo firewall-cmd --add-port=8080/tcp --permanent
success
[ciremy@tp2 ~]$ sudo firewall-cmd --reload
success
[ciremy@tp2 ~]$ sudo firewall-cmd --list-ports
22/tcp 8080/tcp
[ciremy@tp2 ~]$ curl localhost:8080
<!doctype html>
ciremy@ciremy-Aspire-A315-56:~$ curl 10.102.1.11
<!doctype html>
```

# II. Une stack web plus avancée

⚠⚠⚠ **Réinitialiser votre conf Apache avant de continuer** ⚠⚠⚠  
En particulier :

- reprendre le port par défaut
- reprendre l'utilisateur par défaut

## 1. Intro blabla

**Le serveur web `web.tp2.linux` sera le serveur qui accueillera les clients.** C'est sur son IP que les clients devront aller pour visiter le site web.

**Le service de base de données `db.tp2.linux` sera uniquement accessible depuis `web.tp2.linux`.** Les clients ne pourront pas y accéder. Le serveur de base de données stocke les infos nécessaires au serveur web, pour le bon fonctionnement du site web.

---

Bon le but de ce TP est juste de s'exercer à faire tourner des services, un serveur + sa base de données, c'est un peu le cas d'école. J'ai pas envie d'aller deep dans la conf de l'un ou de l'autre avec vous pour le moment, on va se contenter d'une conf minimale.

Je vais pas vous demander de coder une application, et cette fois on se contentera pas d'un simple `index.html` tout moche et on va se mettre dans la peau de l'admin qui se retrouve avec une application à faire tourner. **On va faire tourner un [NextCloud](https://nextcloud.com/).**

En plus c'est utile comme truc : c'est un p'tit serveur pour héberger ses fichiers via une WebUI, style Google Drive. Mais on l'héberge nous-mêmes :)

---

Le flow va être le suivant :

➜ **on prépare d'abord la base de données**, avant de setup NextCloud

- comme ça il aura plus qu'à s'y connecter
- ce sera sur une nouvelle machine `db.tp2.linux`
- il faudra installer le service de base de données, puis lancer le service
- on pourra alors créer, au sein du service de base de données, le nécessaire pour NextCloud

➜ **ensuite on met en place NextCloud**

- on réutilise la machine précédente avec Apache déjà installé, ce sera toujours Apache qui accueillera les requêtes des clients
- mais plutôt que de retourner une bête page HTML, NextCloud traitera la requête
- NextCloud, c'est codé en PHP, il faudra donc **installer une version de PHP précise** sur la machine
- on va donc : install PHP, configurer Apache, récupérer un `.zip` de NextCloud, et l'extraire au bon endroit !

![NextCloud install](./pics/nc_install.png)

## 2. Setup

🖥️ **VM db.tp2.linux**

**N'oubliez pas de dérouler la [📝**checklist**📝](#checklist).**

| Machines        | IP            | Service                 |
| --------------- | ------------- | ----------------------- |
| `web.tp2.linux` | `10.102.1.11` | Serveur Web             |
| `db.tp2.linux`  | `10.102.1.12` | Serveur Base de Données |

### A. Base de données

🌞 **Préparation de la base pour NextCloud**

- une fois en place, il va falloir préparer une base de données pour NextCloud :
  - connectez-vous à la base de données à l'aide de la commande `sudo mysql -u root -p`
  - exécutez les commandes SQL suivantes :

```bash
[ciremy@localhost ~]$ sudo mysql -u root -p
```

```sql
-- Création d'un utilisateur dans la base, avec un mot de passe
-- L'adresse IP correspond à l'adresse IP depuis laquelle viendra les connexions. Cela permet de restreindre les IPs autorisées à se connecter.
-- Dans notre cas, c'est l'IP de web.tp2.linux
-- "pewpewpew" c'est le mot de passe hehe
CREATE USER 'nextcloud'@'10.102.1.11' IDENTIFIED BY 'pewpewpew';

-- Création de la base de donnée qui sera utilisée par NextCloud
CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

-- On donne tous les droits à l'utilisateur nextcloud sur toutes les tables de la base qu'on vient de créer
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'10.102.1.11';

-- Actualisation des privilèges
FLUSH PRIVILEGES;

-- C'est assez générique comme opération, on crée une base, on crée un user, on donne les droits au user sur la base
```

> Par défaut, vous avez le droit de vous connecter localement à la base si vous êtes `root`. C'est pour ça que `sudo mysql -u root` fonctionne, sans nous demander de mot de passe. Evidemment, n'importe quelles autres conditions ne permettent pas une connexion aussi facile à la base.

🌞 **Exploration de la base de données**

```bash

[ciremy@tp2 ~]$ mysql -u nextcloud -h 10.102.1.12 -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.

mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| nextcloud          |
+--------------------+


```

- afin de tester le bon fonctionnement de la base de données, vous allez essayer de vous connecter, comme NextCloud le fera :
  - depuis la machine `web.tp2.linux` vers l'IP de `db.tp2.linux`
  - utilisez la commande `mysql` pour vous connecter à une base de données depuis la ligne de commande
    - par exemple `mysql -u <USER> -h <IP_DATABASE> -p`
    - si vous ne l'avez pas, installez-là
    - vous pouvez déterminer dans quel paquet est disponible la commande `mysql` en saisissant `dnf provides mysql`
- **donc vous devez effectuer une commande `mysql` sur `web.tp2.linux`**
- une fois connecté à la base, utilisez les commandes SQL fournies ci-dessous pour explorer la base

```sql
SHOW DATABASES;
USE <DATABASE_NAME>;
SHOW TABLES;
```

### B. Serveur Web et NextCloud

⚠️⚠️⚠️ **N'OUBLIEZ PAS de réinitialiser votre conf Apache avant de continuer. En particulier, remettez le port et le user par défaut.**

🌞 **Install de PHP**

```bash
[ciremy@tp2 ~]$ sudo dnf config-manager --set-enabled crb

[ciremy@tp2 ~]$ sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y

[ciremy@tp2 ~]$ dnf module list php

[ciremy@tp2 ~]$ sudo dnf module enable php:remi-8.1 -y

[ciremy@tp2 ~]$ sudo dnf install -y php81-php
```

🌞 **Install de tous les modules PHP nécessaires pour NextCloud**

```bash
[ciremy@tp2 ~]$ sudo dnf install -y libxml2 openssl php81-php php81-php-ctype php81-php-curl php81-php-gd php81-php-iconv php81-php-json php81-php-libxml php81-php-mbstring php81-php-openssl php81-php-posix php81-php-session php81-php-xml php81-php-zip php81-php-zlib php81-php-pdo php81-php-mysqlnd php81-php-intl php81-php-bcmath php81-php-gmp
```

🌞 **Récupérer NextCloud**

- créez le dossier `/var/www/tp2_nextcloud/`
  - ce sera notre _racine web_ (ou _webroot_)
  - l'endroit où le site est stocké quoi, on y trouvera un `index.html` et un tas d'autres marde, tout ce qui constitue NextClo :D
- récupérer le fichier suivant avec une commande `curl` ou `wget` : https://download.nextcloud.com/server/prereleases/nextcloud-25.0.0rc3.zip
- extrayez tout son contenu dans le dossier `/var/www/tp2_nextcloud/` en utilisant la commande `unzip`
  - installez la commande `unzip` si nécessaire
  - vous pouvez extraire puis déplacer ensuite, vous prenez pas la tête
  - contrôlez que le fichier `/var/www/tp2_nextcloud/index.html` existe pour vérifier que tout est en place
- assurez-vous que le dossier `/var/www/tp2_nextcloud/` et tout son contenu appartient à l'utilisateur qui exécute le service Apache

```bash
[ciremy@tp2 www]$ mkdir tp2_nextcloud

[ciremy@tp2 ~]$ wget https://download.nextcloud.com/server/prereleases/nextcloud-25.0.0rc3.zip

[ciremy@tp2 ~]$ sudo unzip nextcloud-25.0.0rc3.zip -d /var/www/tp2_nextcloud/

[ciremy@tp2 www]$ sudo chown apache ./tp2_nextcloud/ -R

[ciremy@tp2 www]$ ls -al
drwxr-xr-x.  3 apache root   23 Nov 15 17:49 tp2_nextcloud


```

> A chaque fois que vous faites ce genre de trucs, assurez-vous que c'est bien ok. Par exemple, vérifiez avec un `ls -al` que tout appartient bien à l'utilisateur qui exécute Apache.

🌞 **Adapter la configuration d'Apache**

- regardez la dernière ligne du fichier de conf d'Apache pour constater qu'il existe une ligne qui inclut d'autres fichiers de conf
- créez en conséquence un fichier de configuration qui porte un nom clair et qui contient la configuration suivante :

```bash

[ciremy@tp2 www]$ sudo nano /etc/httpd/conf/httpd.conf


<VirtualHost *:80>
  # on indique le chemin de notre webroot
  DocumentRoot /var/www/tp2_nextcloud/
  # on précise le nom que saisissent les clients pour accéder au service
  ServerName  web.tp2.linux

  # on définit des règles d'accès sur notre webroot
  <Directory /var/www/tp2_nextcloud/>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>

```

🌞 **Redémarrer le service Apache** pour qu'il prenne en compte le nouveau fichier de conf

```bash
[ciremy@tp2 www]$ sudo systemctl restart httpd
```

### C. Finaliser l'installation de NextCloud

➜ **Sur votre PC**

- modifiez votre fichier `hosts` (oui, celui de votre PC, de votre hôte)
  - pour pouvoir joindre l'IP de la VM en utilisant le nom `web.tp2.linux`
- avec un navigateur, visitez NextCloud à l'URL `http://web.tp2.linux`
  - c'est possible grâce à la modification de votre fichier `hosts`
- on va vous demander un utilisateur et un mot de passe pour créer un compte admin
  - ne saisissez rien pour le moment
- cliquez sur "Storage & Database" juste en dessous
  - choisissez "MySQL/MariaDB"
  - saisissez les informations pour que NextCloud puisse se connecter avec votre base
- saisissez l'identifiant et le mot de passe admin que vous voulez, et validez l'installation

🌴 **C'est chez vous ici**, baladez vous un peu sur l'interface de NextCloud, faites le tour du propriétaire :)
