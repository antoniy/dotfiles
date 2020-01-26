#!/usr/bin/env bash
################################################################################
#    Author: Wenxuan                                                           #
#     Email: wenxuangm@gmail.com                                               #
#   Created: 2018-05-31 10:08                                                  #
################################################################################

# From: https://github.com/ryanoasis/devicons-shell/blob/master/devicons-ls
# Author: Ryan L McIntyre
folder_icon=''
file_icon=
declare -A icons=(
[txt]=
[styl]=
[scss]=
[xml]=謹
[htm]=
[html]=
[slim]=
[ejs]=
[css]=
[less]=
[md]=
[markdown]=
[json]=
[js]=
[jsx]=
[rb]=
[php]=
[py]=
[pyc]=
[pyo]=
[pyd]=
[coffee]=
[mustache]=
[hbs]=
[conf]=
[ini]=
[yml]=
[bat]=
[jpg]=
[jpeg]=
[bmp]=
[png]=
[gif]=
[ico]=
[twig]=
[cpp]=
[c++]=
[cxx]=
[cc]=
[cp]=
[c]=
[hs]=
[lhs]=
[lua]=
[java]=
[sh]=
[fish]=
[ml]=λ
[mli]=λ
[diff]=
[db]=
[sql]=
[dump]=
[clj]=
[cljc]=
[cljs]=
[edn]=
[scala]=
[go]=
[dart]=
[xul]=
[sln]=
[suo]=
[pl]=
[pm]=
[t]=
[rss]=
[fs]=
[fsscript]=
[fsx]=
[fs]=
[fsi]=
[rs]=
[rlib]=
[d]=
[erl]=
[hrl]=
[vim]=
[ai]=
[psd]=
[psb]=
[ts]=
[jl]=
)

function iconful_file() {
    while read -r file; do
        ext="${file##*.}"
        icon=${icons[$ext]:-$file_icon}
        echo " $icon $file"
    done
}

function iconful_dir() {
    while read -r file; do
        echo -e " $folder_icon $file"
    done
}

function iconful() {
    while read -r file; do
        if [[ -d "$file" ]]; then
            icon="$folder_icon"
        else
            ext="${file##*.}"
            icon=${icons[$ext]:-$file_icon}
        fi
        echo " $icon $file"
    done
}

DIR=false
FILE=false

while true; do
    case "$1" in
        -f | --file )      FILE=true && DIR=false ; shift ;;
        -d | --directory ) DIR=true && FILE=false ; shift ;;
        -- )               shift; break                   ;;
        * )                break                          ;;
    esac
done

if [[ "$FILE" == "true" ]]; then
    iconful_file
elif [[ "$DIR" == "true" ]]; then
    iconful_dir
else
    iconful
fi
