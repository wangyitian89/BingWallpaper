#!/bin/bash - 

# crontab
# 11 11 * * * sh /project/BingWallpaper.sh > /dev/null 2>&1
# 02 18 10,20,30 * * find /tmp/ -type f -name "BingWallpaper*" -ctime +40 -delete > /dev/null 2>&1

download_dir=$HOME'/Pictures/bing'
bing_wallpaper_urls_log=$HOME'/Pictures/photo_urls.log'
log_file='/tmp/BingWallpaper.log.'`date "+%Y%m"`

mkdir -p $download_dir

log () {
    msg=$1
    logfile=$2
    time=`date "+%Y-%m-%d %H:%M:%S"`
    if [ "x$log_file" == "x" ]; then
        echo "[$time] $msg"
    else
        echo "[$time] $msg" >> $logfile
    fi
}

download_from_url () {
	curl -sL $1 
}

get_photo_urls () {
    echo `curl -sL "$1"` | tr '"' '\n' | grep jpg
}

langs="
ar-SA
de-AT
de-CH
de-DE
en-AU
en-CA
en-GB
en-ID
en-IN
en-MY
en-US
en-ZA
es-AR
es-ES
es-MX
es-US
fr-BE
fr-CA
fr-CH
fr-FR
it-IT
ja-JP
ko-KR
nb-NO
nl-BE
nl-NL
pl-PL
pt-BR
ru-RU
sv-SE
tr-TR
zh-CN
zh-HK
zh-TW
"

wallpaper_urls=''
for lang in $langs
do
    bing_url="http://global.bing.com/HPImageArchive.aspx?format=js&idx=0&n=12&setmkt=${lang}"

    wallpaper_urls=$(get_photo_urls $bing_url)" ${wallpaper_urls}"
done
# wallpaper url is like /az/hprichbg/rb/EternalFlame_EN-CA10974314579_1920x1080.jpg

# uniq wallpapers by name like /az/hprichbg/rb/EternalFlame_1920x1080.jpg
wallpaper_urls=`echo ${wallpaper_urls} | tr ' ' '\n' | awk -F '_' '{a[$1"_"$3]=$0}END{for (filename in a) print a[filename]}'`
log "${wallpaper_urls}" $log_file

# download each wallpaper
for url in $wallpaper_urls
do
    url="http://www.bing.com"$url

    # http://www.bing.com/az/hprichbg/rb/EternalFlame_EN-CA10974314579_1920x1080.jpg =>
    # $download_dir/EternalFlame_1920x1080.jpg
    wallpaper=$download_dir/`echo $url | tr "/" "\n" | grep jpg | awk -F '_' '{print $1 "_"$3}'`

    if [ -e $wallpaper ]
    then
        log "$wallpaper is exits!" $log_file
        log "all:\t$url" $bing_wallpaper_urls_log
        continue
    fi
    log "new:\t$url\t$wallpaper" $bing_wallpaper_urls_log
    download_from_url $url > $wallpaper
    log "$wallpaper is downloaded successed from $url!" $log_file
done
