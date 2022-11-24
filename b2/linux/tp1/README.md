# Tp1

## Préparation de la machine

ping des machines

```bash
[ciremy@localhost ~]$ ping 10.101.1.12
PING 10.101.1.12 (10.101.1.12) 56(84) bytes of data.
64 bytes from 10.101.1.12: icmp_seq=1 ttl=64 time=1.40 ms
64 bytes from 10.101.1.12: icmp_seq=2 ttl=64 time=0.852 ms
64 bytes from 10.101.1.12: icmp_seq=3 ttl=64 time=0.809 ms
64 bytes from 10.101.1.12: icmp_seq=4 ttl=64 time=0.786 ms

--- 10.101.1.12 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3004ms
```

```bash
[Ciremy@node1 ~]$ hostname
node1.tp1.b2
```

```bash
[Ciremy@node2 ~]$ hostname
node2.tp1.b2
```

```bash
[Ciremy@node2 ~]$ ping 10.101.1.11
PING 10.101.1.11 (10.101.1.11) 56(84) bytes of data.
64 bytes from node1.tp1.b2 (10.101.1.11): icmp_seq=1 ttl=64 time=1.28 ms
64 bytes from node1.tp1.b2 (10.101.1.11): icmp_seq=2 ttl=64 time=0.845 ms
64 bytes from node1.tp1.b2 (10.101.1.11): icmp_seq=3 ttl=64 time=0.830 ms
64 bytes from node1.tp1.b2 (10.101.1.11): icmp_seq=4 ttl=64 time=0.971 ms

--- node1.tp1.b2 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3008ms
```

```bash
[Ciremy@node1 ~]$ dig ynov.com
ynov.com.               206     IN      A       172.67.74.226
ynov.com.               206     IN      A       104.26.10.233
ynov.com.               206     IN      A       104.26.11.233

```

```bash
[Ciremy@node2 ~]$ dig ynov.com
ynov.com.               232     IN      A       104.26.10.233
ynov.com.               232     IN      A       104.26.11.233
ynov.com.               232     IN      A       172.67.74.226

```

```bash
[Ciremy@node1 ~]$ sudo firewall-cmd --list-all

public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client ssh
  ports:
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

# I Utilisateurs

## 1 Création et configuration

Pour créer un nouvel utilsateur :

```bash
[Ciremy@node1 ~]$ sudo useradd toto --home /home/toto -s /bin/bash
```

```bash
[Ciremy@node1 ~]$ cat /etc/passwd
toto:x:1001:1001::/home/toto:/bin/bash
```

Pour créer un nouveau groupe :

```bash
sudo groupadd admins
```

```bash
sudo visudo /etc/sudoers
```

```bash
%admins  ALL=(ALL)       ALL
```

```bash
sudo usermod -a -G admins toto
```

```bash
sudo cat /etc/shadow
```

## 2 SSH

Il faut d'abord créer une clé ssh du côté du poste client de l'administrateur

```bash
ssh-keygen -t rsa -b 4096
```

et la donner à notre vm :

```bash
ssh-copy-id toto@10.101.1.11
```

```bash
ssh toto@10.101.1.11
Last login: Mon Nov 14 12:59:21 2022
```

# II Partitionnement

```bash
[toto@node1 ~]$ lsblk
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda           8:0    0    8G  0 disk
├─sda1        8:1    0    1G  0 part /boot
└─sda2        8:2    0    7G  0 part
  ├─rl-root 253:0    0  6.2G  0 lvm  /
  └─rl-swap 253:1    0  820M  0 lvm  [SWAP]
sdb           8:16   0    3G  0 disk
sdc           8:32   0    3G  0 disk
sr0          11:0    1 1024M  0 rom
```

Sdb et sdc sont les disques qu'on a créer

Ajout des disques en tant que Physical Volume dans LVM

```bash
[toto@node1 ~]$ sudo pvcreate /dev/sdb
[sudo] password for toto:
  Physical volume "/dev/sdb" successfully created.
[toto@node1 ~]$ sudo pvcreate /dev/sdc
  Physical volume "/dev/sdc" successfully created.
[toto@node1 ~]$ sudo pvs
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VB19c59981-83061a07_ PVID 3tUMb3znbvaOY5cITUE18fThmXV91ABI last seen on /dev/sda2 not found.
  PV         VG Fmt  Attr PSize PFree
  /dev/sdb      lvm2 ---  3.00g 3.00g
  /dev/sdc      lvm2 ---  3.00g 3.00g
```

```bash
sudo vgcreate data /dev/sdb
[sudo] password for toto:
  Volume group "data" successfully created
[toto@node1 ~]$ sudo vgextend data /dev/sdc
  Volume group "data" successfully extended
[toto@node1 ~]$ sudo vgs
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VB19c59981-83061a07_ PVID 3tUMb3znbvaOY5cITUE18fThmXV91ABI last seen on /dev/sda2 not found.
  VG   #PV #LV #SN Attr   VSize VFree
  data   2   0   0 wz--n- 5.99g 5.99g
```

Ensuite on va créer des logical volumes à partir du groupe data :

```bash
[toto@node1 ~]$ sudo lvcreate -L 1G data -n part1
  Logical volume "part1" created.
[toto@node1 ~]$ sudo lvcreate -L 1G data -n part2
  Logical volume "part2" created.
[toto@node1 ~]$ sudo lvcreate -L 1G data -n part3
  Logical volume "part3" created.
[toto@node1 ~]$ sudo lvs
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VB19c59981-83061a07_ PVID 3tUMb3znbvaOY5cITUE18fThmXV91ABI last seen on /dev/sda2 not found.
  LV    VG   Attr       LSize Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  part1 data -wi-a----- 1.00g
  part2 data -wi-a----- 1.00g
  part3 data -wi-a----- 1.00g
```

formatage en ext4

```bash
[toto@node1 ~]$ sudo mkfs -t ext4 /dev/data/part1
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 262144 4k blocks and 65536 inodes
Filesystem UUID: e4f561cf-a35c-4429-91db-e2e0b69babe9
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done
```

montage des partitions

```bash
[toto@node1 ~]$ sudo mount /dev/data/part1 /mnt/part1
[toto@node1 ~]$ sudo mount /dev/data/part2 /mnt/part2
[toto@node1 ~]$ sudo mount /dev/data/part3 /mnt/part3
[toto@node1 ~]$ sudo mount
/dev/mapper/data-part1 on /mnt/part1 type ext4 (rw,relatime,seclabel)
/dev/mapper/data-part2 on /mnt/part2 type ext4 (rw,relatime,seclabel)
/dev/mapper/data-part3 on /mnt/part3 type ext4 (rw,relatime,seclabel)
[toto@node1 ~]$ df -h
Filesystem              Size  Used Avail Use% Mounted on
/dev/mapper/data-part1  974M   24K  907M   1% /mnt/part1
/dev/mapper/data-part2  974M   24K  907M   1% /mnt/part2
/dev/mapper/data-part3  974M   24K  907M   1% /mnt/part3
```

montage automatique au démarrage du système

```bash
[toto@node1 ~]$ nano /etc/fstab
/dev/mapper/data-part1 /mnt/part1 ext4 defaults 0 0
/dev/mapper/data-part2 /mnt/part2 ext4 defaults 0 0
/dev/mapper/data-part3 /mnt/part3 ext4 defaults 0 0
```

# III Gestion de services

## 1 Interaction avec un service existant

```bash
[toto@node1 ~]$ sudo systemctl is-active firewalld
[sudo] password for toto:
active
```

```bash
[toto@node1 ~]$ sudo systemctl is-enabled firewalld
enabled
```

## 2 Création de service

### A Unité simpliste

```bash
[toto@node1 ~]$ sudo firewall-cmd --add-port=8888/tcp --permanent
success
```

```bash
[Ciremy@node2 ~]$ curl 10.101.1.11:8888
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Directory listing for /</title>
</head>
<body>
<h1>Directory listing for /</h1>
<hr>
<ul>
<li><a href="afs/">afs/</a></li>
<li><a href="bin/">bin@</a></li>
<li><a href="boot/">boot/</a></li>
<li><a href="dev/">dev/</a></li>
<li><a href="etc/">etc/</a></li>
<li><a href="home/">home/</a></li>
<li><a href="lib/">lib@</a></li>
<li><a href="lib64/">lib64@</a></li>
<li><a href="media/">media/</a></li>
<li><a href="mnt/">mnt/</a></li>
<li><a href="opt/">opt/</a></li>
<li><a href="proc/">proc/</a></li>
<li><a href="root/">root/</a></li>
<li><a href="run/">run/</a></li>
<li><a href="sbin/">sbin@</a></li>
<li><a href="srv/">srv/</a></li>
<li><a href="sys/">sys/</a></li>
<li><a href="tmp/">tmp/</a></li>
<li><a href="usr/">usr/</a></li>
<li><a href="var/">var/</a></li>
</ul>
<hr>
</body>
</html>
```

### B Modification de l'unité

```bash
[toto@node1 ~]$ sudo useradd web --home /home/web -s /bin/bash
```

```bash
sudo usermod -a -G admins web
```

```bash
ls -l
total 0
drwxr-xr-x. 2 web root 17 Nov 14 20:00 meow
```

```bash
[web@node1 ~]$ cat /etc/systemd/system/web.service
[Unit]
Description=Very simple web service

[Service]
ExecStart=/bin/python3 -m http.server 8888
User=web
WorkingDirectory=/var/www/meow

[Install]
WantedBy=multi-user.target
```

On ajoute les 2 dernieres ligne dans la partie "Service"

```bash
[Ciremy@node2 ~]$ curl 10.101.1.11:8888
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Directory listing for /</title>
</head>
<body>
<h1>Directory listing for /</h1>
<hr>
<ul>
<li><a href="cat">cat</a></li>
</ul>
<hr>
</body>
</html>
```

Le serveur fonctionne bien
