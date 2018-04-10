#!/bin/bash - 
source ~/bin/bash-logger.sh # https://github.com/wangyitian89/bash-logger.git
MD5=/sbin/md5

# crontab
# 11 11 * * * sh /project/BingWallpaper.sh > /dev/null 2>&1
# 02 18 10,20,30 * * find /tmp/ -type f -name "BingWallpaper*" -ctime +40 -delete > /dev/null 2>&1

export LOGFILE=/tmp/BingWallpaper.log.`date "+%Y%m"`
export LOG_DATE_FORMAT='+%F %T'                         # Eg: 2014-09-07 21:51:57
export LOG_FORMAT='%DATE %PID [%LEVEL] %MESSAGE'

download_dir=$HOME'/Pictures/bing'
bing_wallpaper_urls_log=$HOME'/Pictures/photo_urls.log'

mkdir -p $download_dir

function hash() {
    local path=$1
    echo $path | $MD5 | head -c 1
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
wallpaper_urls=`echo ${wallpaper_urls} | tr ' ' '\n' | awk -F '_' '{a[$1"_"$3]=$0}END{for (filename in a) print a[filename]}' | tr '\n' ' '`
DEBUG "${wallpaper_urls}"

# download each wallpaper
for url in $wallpaper_urls
do
    url="http://www.bing.com"$url

    # http://www.bing.com/az/hprichbg/rb/EternalFlame_EN-CA10974314579_1920x1080.jpg =>
    # $download_dir/EternalFlame_1920x1080.jpg
    file=`echo $url | tr "/" "\n" | grep jpg | awk -F '_' '{print $1 "_"$3}'`
    hash_dir=`hash $file`
    wallpaper=$download_dir/$hash_dir/$file

    if [ -e $wallpaper ]
    then
        INFO "exist\t$url\t$wallpaper"
        continue
    fi
    download_from_url $url > $wallpaper
    INFO "new\t$url\t$wallpaper"
done
