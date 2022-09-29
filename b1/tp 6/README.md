# Partie 1 : Préparation de la machine `backup.tp6.linux`

**La machine `backup.tp6.linux` sera chargée d'héberger les sauvegardes.**

Autrement dit, avec des mots simples : la machine `backup.tp6.linux` devra stocker des fichiers, qui seront des archives compressées.

Rien de plus simple non ? Un fichier, ça se met dans un dossier, et walou.

**ALORS OUI**, c'est vrai, mais on va aller un peu plus loin que ça :3

**Ce qu'on va faire, pour augmenter le niveau de sécu de nos données, c'est les stocker sur un espace vraiment dédié. C'est à dire une partition dédiée, sur un disque dur dédié.**

Au menu :

- ajouter un disque dur à la VM
- créer une nouvelle partition sur le disque avec LVM
- formater la partition pour la rendre utilisable
- monter la partition pour la rendre accessible
- rendre le montage de la partition automatique, pour qu'elle soit toujours accessible

> On ne travaille que sur `backup.tp6.linux` dans cette partie !

# I. Ajout de disque

Pour ajouter un disque, bah vous allez au magasin et vous achetez un disque ? n_n

Nan, en vrai, les VMs, c'est virtuel. Leurs disques sont virtuels. Donc on va simplement ajouter un disque virtuel à la VM, depuis VirtualBox.

Je vous laisse faire pour cette partie, avec vos ptites mains, vot' ptite tête et vot' p'tit pote Google. Rien de bien sorcier.

🌞 **Ajouter un disque dur de 5Go à la VM `backup.tp6.linux`**

```bash
[titi@backup ~]$ lsblk
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda           8:0    0    8G  0 disk
|-sda1        8:1    0    1G  0 part /boot
`-sda2        8:2    0    7G  0 part
  |-rl-root 253:0    0  6.2G  0 lvm  /
  `-rl-swap 253:1    0  820M  0 lvm  [SWAP]
sdb           8:16   0    5G  0 disk
sr0          11:0    1 1024M  0 rom

```

# II. Partitioning

> [**Référez-vous au mémo LVM pour réaliser cette partie.**](../../cours/memos/lvm.md)

Le partitionnement est obligatoire pour que le disque soit utilisable. Ici on va rester simple : une seule partition, qui prend toute la place offerte par le disque.

Comme vu en cours, le partitionnement dans les systèmes GNU/Linux s'effectue généralement à l'aide de LVM.

Allons !

🌞 **Partitionner le disque à l'aide de LVM**

```bash
[titi@backup ~]$ sudo pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.

[titi@backup ~]$ sudo pvs
  PV         VG Fmt  Attr PSize  PFree
  /dev/sda2  rl lvm2 a--  <7.00g    0
  /dev/sdb      lvm2 ---   5.00g 5.00g

[titi@backup ~]$ sudo vgcreate backup /dev/sdb
  Volume group "backup" successfully created

[titi@backup ~]$ sudo vgs | grep backup
  backup   1   0   0 wz--n- <5.00g <5.00g

[titi@backup ~]$ sudo lvcreate -l 100%FREE backup -n data
[sudo] password for titi:
  Logical volume "data" created.

[titi@backup ~]$ sudo lvs
[sudo] password for titi:
  LV   VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  data backup -wi-a-----  <5.00g
  root rl     -wi-ao----  <6.20g
  swap rl     -wi-ao---- 820.00m
```

🌞 **Formater la partition**

```bash
mke2fs 1.45.6 (20-Mar-2020)
Creating filesystem with 1309696 4k blocks and 327680 inodes
Filesystem UUID: 1e2ad4a5-1a64-4b20-9343-493bcb610e92
Superblock backups stored on blocks:
	32768, 98304, 163840, 229376, 294912, 819200, 884736

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

```

🌞 **Monter la partition**

```bash
[titi@backup ~]$ sudo mkdir /mnt/backup
[titi@backup ~]$ sudo mount /dev/backup/data /mnt/backup

[titi@backup ~]$ df -h
Filesystem               Size  Used Avail Use% Mounted on
devtmpfs                 386M     0  386M   0% /dev
tmpfs                    405M     0  405M   0% /dev/shm
tmpfs                    405M  5.6M  400M   2% /run
tmpfs                    405M     0  405M   0% /sys/fs/cgroup
/dev/mapper/rl-root      6.2G  2.1G  4.2G  34% /
/dev/sda1               1014M  216M  799M  22% /boot
tmpfs                     81M     0   81M   0% /run/user/1000
/dev/mapper/backup-data  4.9G   20M  4.6G   1% /mnt/backup

[titi@backup ~]$ sudo nano /mnt/backup/test
[titi@backup ~]$ sudo cat /mnt/backup/test
test

[titi@backup ~]$ cat /etc/fstab | grep /mnt/backup
/dev/mapper/backup-data /mnt/backup ext4 defaults 0 0

[titi@backup ~]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
none                     : ignored
/mnt/backup              : already mounted

```

# Partie 2 : Setup du serveur NFS sur `backup.tp6.linux`

🌞 **Préparer les dossiers à partager**

```bash
[titi@backup ~]$ sudo mkdir /mnt/backup/web.tp6.linux
[sudo] password for titi:
[titi@backup ~]$ sudo mkdir /mnt/backup/db.tp6.linux

```

🌞 **Install du serveur NFS**

```bash
[titi@backup ~]$ sudo mkdir /mnt/backup/web.tp6.linux
[sudo] password for titi:
[titi@backup ~]$ sudo mkdir /mnt/backup/db.tp6.linux

```

🌞 **Conf du serveur NFS**

- fichier `/etc/idmapd.conf`

```bash
# Trouvez la ligne "Domain =" et modifiez la pour correspondre à notre domaine :
Domain = tp6.linux
```

- fichier `/etc/exports`

```bash
# Pour ajouter un nouveau dossier /toto à partager, en autorisant le réseau `192.168.1.0/24` à l'utiliser
/toto 192.168.1.0/24(rw,no_root_squash)
```

Dans notre cas, vous n'ajouterez pas le dossier `/toto` à ce fichier, mais évidemment `/backup/web.tp6.linux/` et `/backup/db.tp6.linux/` (deux partages donc).  
Aussi, le réseau à autoriser n'est PAS `192.168.1.0/24` dans ce TP, à vous d'adapter la ligne.

Les machins entre parenthèses `(rw,no_root_squash)` sont les options de partage. **Vous expliquerez ce que signifient ces deux-là.**

🌞 **Démarrez le service**

- le service s'appelle `nfs-server`
- après l'avoir démarré, prouvez qu'il est actif
- faites en sorte qu'il démarre automatiquement au démarrage de la machine

🌞 **Firewall**

- le port à ouvrir et le `2049/tcp`
- prouvez que la machine écoute sur ce port (commande `ss`)

---

Ok le service est up & runnin ! Reste plus qu'à le tester : go sur [la partie 3 pour setup les clients NFS](./part3.md).
