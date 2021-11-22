if [ ! -d /srv/yt/downloads ]; then
    echo "Le fichier n'existe pas"
        exit 1
        else
if [ ! -d /var/log/yt ]; then
	echo "Le fichier de log n'es pas présent"
	exit 1
	else
if [[ $# -eq 0 ]]; then
	echo Pas de lien youtube
	exit 1
fi
sudo youtube-dl -f mp4 -q --write-description -o '/srv/yt/downloads/%(title)s/%(title)s.%(ext)s' $1

title=$(youtube-dl -e $1)
sudo mv /srv/yt/downloads/"$title"/"$title".description /srv/yt/downloads/"$title"/description 
echo Video $1 was downloaded.
echo Path : /srv/yt/downloads/"$title"/"$title".mp4


echo [$(date "+%D %T")] Video $1 was downloaded. File path : /srv/yt/downloads/"$title"/"$title".mp4 > /var/log/yt/download.log
fi
fi
