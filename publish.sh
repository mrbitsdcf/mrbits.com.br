#!/bin/bash

get_date () {
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] - $1"
}

get_date "Generating pages"
hugo

get_date "Publishing pages"
rsync -vae ssh public/* ps-web-1:/var/www/html/mrbits.com.br/

get_date "Enjoy your new site"
