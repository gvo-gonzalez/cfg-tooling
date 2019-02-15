#!/usr/bin/env bash

function generate_app_key {
    php -r "echo md5(uniqid()).\"\n\";"
}

APP_KEY=$(generate_app_key)

cd $1
sed -e s/APP_KEY=.*$/APP_KEY=${APP_KEY}/g .env.example > .env
