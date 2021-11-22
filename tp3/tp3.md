# TP 3 : A little script

-[ Script carte d'identité](#script-carte-didentité)

-[ Script youtube-dl](#script-youtube-dl)

-[ MAKE IT A SERVICE](#make-it-a-service)

-[ Bonus](#bonus)

## Script carte d'identité

```
sudo bash /srv/idcard/idcard.sh
    Machine name : ciremy-Aspire-A315-56
    OS : Ubuntu and kernel version is 20.04.3
    IP : 10.33.16.150
    RAM : 3809340 / 7931092 KB
    Disque : 60 Go left
    Top 5 processes by RAM usage :
    - /usr/share/discord/Discord
    - /opt/google/chrome/chrome
    - /usr/share/code/code
    - /opt/google/chrome/chrome
    - /usr/bin/gnome-shell
    listening port :
    - 6463 : Discord
    - 45991 : code
    Here's your random cat : https://cdn2.thecatapi.com/images/aqv.jpg
```

## Script youtube-dl

```
sudo bash /srv/yt/yt.sh https://www.youtube.com/watch?v=sNx57atloH8
    Video https://www.youtube.com/watch?v=sNx57atloH8
    File path : /srv/yt/downloads/tomato anxiety/tomato anxiety.mp4
```

## MAKE IT A SERVICE

```
systemctl status yt.service
    ● yt.service - "Processus pour dl des vidéos"
        Loaded: loaded (/etc/systemd/system/yt.service; disabled; vendor preset: enabled)
        Active: active (running) since Fri 2021-11-19 12:31:23 CET; 1min 45s ago
    Main PID: 4800 (bash)
        Tasks: 2 (limit: 2312)
        Memory: 772.0K
        CGroup: /system.slice/yt.service
                ├─4800 /usr/bin/bash /srv/yt/yt-v2.sh
                └─4887 sleep 5s
    nov. 19 12:31:23 node1.tp2.linux systemd[1]: Started "Processus pour dl des vidéos".
    nov. 19 12:31:39 node1.tp2.linux bash[4802]: Video https://www.youtube.com/watch?v=sNx57atloH8 was downloaded
    nov. 19 12:31:39 node1.tp2.linux bash[4802]: File path : /srv/yt/downloads/tomato anxiety/tomato anxiety.mp4
```

```
journalctl -xe -u yt
    [...]
    -- The job identifier is 3507.
    nov. 19 12:31:39 node1.tp2.linux bash[4802]: Video https://www.youtube.com/watch?v=sNx57atloH8 was downloaded
    nov. 19 12:31:39 node1.tp2.linux bash[4802]: File path : /srv/yt/downloads/tomato anxiety/tomato anxiety.mp4
```

## Bonus

[![asciicast](https://asciinema.org/a/PdGhqOL66w6jZuVqTZ6hHJ3Uw.svg)](https://asciinema.org/a/PdGhqOL66w6jZuVqTZ6hHJ3Uw)
