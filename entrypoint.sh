#!/bin/sh

# XMLGen
header='<?xml version="1.0" encoding="utf-8" ?>
<aseco_plugins>'
footer='</aseco_plugins>'

fmt='   <plugin>%s</plugin>\n'

{
printf "%s\n" "$header"
find plugins -maxdepth 1 -type f | sed -e 's#plugins/##g' | while read line
do
    printf "$fmt" "$line"
done
printf "%s\n" "$footer"
} > plugins.xml

# ENV validation
# config.xml

if [ -z "$MASTERADMIN_LOGIN" ]; then
    echo "WARN | No masteradmin login was specified. It is advised to have the system administrator also function as masteradmin."
    echo "WARN | continuing..."
fi

if [ -z "$SUPERADMIN_PASSWORD" ]; then
    echo "ERROR | No superadmin password was given."
    echo "ERROR | exiting..."
    exit 1
fi

if [ -z "$TMSERVER_HOST" ]; then
    echo "WARN | Host address of the trackmania server was not given."
    echo "WARN | Assuming localhost..."
    export TMSERVER_HOST="localhost"
fi

if [ -z "$TMSERVER_PORT" ]; then
    echo "WARN | Port for the connection to trackmania server was not given."
    echo "WARN | Assuming 5000..."
    export TMSERVER_PORT="5000"
fi

envsubst < templates/_config.xml > templates/config.xml
ln -s templates/config.xml config.xml

# dedimania.xml

if [ -z "$SERVER_LOGIN" ]; then
    echo "ERROR | Server login code was not given."
    echo "ERROR | Exiting..."
    exit 1
fi

if [ -z "$SERVER_PASSWORD" ]; then
    echo "ERROR | Server login password was not given."
    echo "ERROR | Exiting..."
    exit 1
fi

if [ -z "$SERVER_NATION" ]; then
    echo "WARN | Server nation was not given."
    echo "WARN | Assuming GER..."
    export SERVER_NATION="GER"
fi

envsubst < templates/_dedimania.xml > templates/dedimania.xml
ln -s templates/dedimania.xml dedimania.xml

# localdatabase.xml

if [ -z "$MYSQL_HOST" ]; then
    echo "WARN | MySQL host address was not given."
    echo "WARN | Assuming localhost..."
    export MYSQL_HOST="127.0.0.1"
fi

if [ -z "$MYSQL_LOGIN" ]; then
    echo "ERROR | MySQL login was not given."
    echo "ERROR | Exiting..."
    exit 1
fi

if [ -z "$MYSQL_PASSWORD" ]; then
    echo "ERROR | MySQL password was not given."
    echo "ERROR | Exiting..."
    exit 1
fi

if [ -z "$MYSQL_DATABASE" ]; then
    echo "ERROR | MySQL database was not given."
    echo "ERROR | Exiting..."
    exit 1
fi

envsubst < templates/_localdatabase.xml templates/localdatabase.xml
ln -s templates/localdatabase.xml localdatabase.xml

# creating plugin configuration files

if [ -d "config" ]; then
    if [ "$(ls -A config/)" ]; then
        ln -sf config/* .
    fi
fi

exec "$@"
