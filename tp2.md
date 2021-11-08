# TP2 : Explorer et manipuler le système

## Nommer la machine

🌞 **Changer le nom de la machine**

```bash
sudo hostname node1.tp2.linux
# deco/reco
sudo nano /etc/hostname
cat /etc/hostname
node1.tp2.linux
```

# Intro

## 3. Config réseau

🌞 **Config réseau fonctionnelle**

```bash
toto@node1:~$ ping 1.1.1.1
#PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
#64 bytes from 1.1.1.1: icmp_seq=1 ttl=63 time=25.4 ms
toto@node1:~$ ping ynov.com

#PING ynov.com (92.243.16.143) 56(84) bytes of data.
#64 bytes from xvm-16-143.dc0.ghst.net (92.243.16.143): icmp_seq=1 ttl=63 time=22.5 ms
ciremy@ciremy-Aspire-A315-56:~$ ping 192.168.56.101
#PING 192.168.56.101 (192.168.56.101) 56(84) bytes of data.
#64 octets de 192.168.56.101 : icmp_seq=1 ttl=64 temps=0.453 ms

```

# Partie 1 : SSH

# II. Setup du serveur SSH

## 1. Installation du serveur

🌞 **Installer le paquet**

```bash=
toto@node1:~$ sudo apt install openssh-server

```

## 2. Lancement du service SSH

🌞 **Lancer le service `ssh`**

```bash=
toto@node1:~$ systemctl start ssh
#Authentication is required to start 'ssh.service'.

toto@node1:~$ systemctl status ssh
#● ssh.service - OpenBSD Secure Shell server

```

## 3. Etude du service SSH

🌞 **Analyser le service en cours de fonctionnement**

```bash=
toto@node1:~$ systemctl status ssh
#● ssh.service - OpenBSD Secure Shell server
toto@node1:~$ ps -ef | grep ssh
#root        1522       1  0 16:19 ?        00:00:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
#root        2573    1522  0 16:19 ?        00:00:00 sshd: toto [priv]
#toto        2656    2573  0 16:19 ?        00:00:00 sshd: toto@pts/1

toto@node1:~$ ss -ltnp
#LISTEN      0           128                    0.0.0.0:22                  0.0.0.0:*
#LISTEN      0           128                       [::]:22                     [::]:*


```

🌞 **Connectez vous au serveur**

```bash
ssh toto@192.168.56.101

Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.11.0-38-generic x86_64)


```

## 4. Modification de la configuration du serveur

🌞 **Modifier le comportement du service**

```bash

cat sshd_config

#	$OpenBSD: sshd_config,v 1.103 2018/04/09 20:41:22 tj Exp $

# This is the sshd server system-wide configuration file.  See
# sshd_config(5) for more information.

# This sshd was compiled with PATH=/usr/bin:/bin:/usr/sbin:/sbin

# The strategy used for options in the default sshd_config shipped with
# OpenSSH is to specify options with their default value where
# possible, but leave them commented.  Uncommented options override the
# default value.

Include /etc/ssh/sshd_config.d/*.conf

Port 2000
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::


```

# II. Setup du serveur FTP

Toujours la même routine :

- **1. installation de paquet**
  - avec le gestionnaire de paquet de l'OS
- **2. configuration** dans un fichier de configuration
  - avec un éditeur de texte
  - les fichiers de conf sont de simples fichiers texte
- **3. lancement du service**
  - avec une commande `systemctl start <NOM_SERVICE>`

> **_Pour toutes les commandes tapées qui figurent dans le rendu, je veux la commande ET son résultat. S'il manque l'un des deux, c'est useless._**

## 1. Installation du serveur

🌞 **Installer le paquet `vsftpd`**

```bash
toto@node1:~$ sudo apt install vsftpd
```

## 2. Lancement du service FTP

🌞 **Lancer le service `vsftpd`**

```bash
toto@node1:/$ systemctl start vsftpd
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ===
Authentication is required to start 'vsftpd.service'.
Authenticating as: toto,,, (toto)


toto@node1:/$ systemctl status vsftpd
 vsftpd.service - vsftpd FTP server
     Loaded: loaded (/lib/systemd/system/vsftpd.service; enabled; vendor preset>
     Active: active (running) since Sun 2021-11-07 16:04:39 CET; 22h ago
```

> Vous pouvez aussi faire en sorte que le service FTP se lance automatiquement au démarrage avec la commande `systemctl enable vsftpd`.

## 3. Etude du service FTP

🌞 **Analyser le service en cours de fonctionnement**

```bash
toto@node1:/$ ps -ef

root       24638       1  0 14:04 ?        00:00:00 /usr/sbin/vsftpd /etc/vsftpd
toto       29419   24312  0 15:07 pts/1    00:00:00 systemctl enable vsftpd

toto@node1:/var/log$ ss -lt

LISTEN    0         32                         *:ftp                       *:*

toto@node1:/var/log$ journalctl -u vsftpd

-- Logs begin at Mon 2021-10-25 15:36:31 CEST, end at Mon 2021-11-08 22:26:51 CET. --
nov. 07 16:04:39 node1.tp2.linux systemd[1]: Starting vsftpd FTP server...
nov. 07 16:04:39 node1.tp2.linux systemd[1]: Started vsftpd FTP server.

```
