#!/bin/bash

# if 文
if [ "$1" = "-h" -o "$1" = "" ]; then
  echo "Usage: $0 FQDN"
  echo "ex: $0 test.asaichi.co.jp"
  exit
fi

FQDN=$1
ROOT_CN="Asaichi CA ${FQDN}"
SCRIPT_DIR=$(cd $(dirname $(readlink $0 || echo $0));pwd)

if [ "$(uname)" == 'Darwin' ]; then
    OS='Mac'
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
    OS='Linux'
else
    # デフォルトはmacOSにしとく。
    OS='Mac'
fi

function confirm_domain() {
    echo "-----------------------------------------------"
    echo "対象のドメインは\"${1}\"でいいですか？[y/n]"
    echo "Is \"${1}\" the target domain?[y/n]"

    while read -p "" yn ; do
        expr "$yn" >/dev/null 2>&1

        if [ $? -ge 1 ]; then
            echo "Please enter y or n."
            continue
        elif [ $yn = "y" ]; then
            break
        elif [ $yn = "n" ]; then
            exit
        fi

        echo "Please enter y or n."
    done
}

function create_certificate() {
    echo "-----------------------------------------------"
    echo "独自のルート証明書を作って\"${1}\"の証明書を作成しますか？ [y/n]"
    echo "Do you want to create a SSL certificate using your own root certificate? [y/n]"
    while read -p "" yn ; do
        expr "$yn" >/dev/null 2>&1

        if [ $? -ge 1 ]; then
          echo "Please enter y or n."
          continue
        elif [ $yn = "y" ]; then
            if [ $4 == 'Mac' ]; then
                CNF_PATH=/System/Library/OpenSSL/openssl.cnf
            else
                CNF_PATH=/etc/ssl/openssl.cnf
            fi

            cd ${2}
            rm -rf ./tls
            rm -rf ./demoCA
            mkdir ./tls
            mkdir ./demoCA
            touch ./demoCA/index.txt
            echo 01 > ./demoCA/serial
            openssl genrsa -out ./demoCA/ca.key 2048
            openssl req -new \
                -key ./demoCA/ca.key \
                -out ./demoCA/ca.csr  \
                -subj "/C=JP/ST=Tokyo/L=Chuo-ku/O=Asaichi/CN=${3}" \
                -sha256
            openssl x509 -days 365 -in ./demoCA/ca.csr -req -signkey ./demoCA/ca.key -out ca.crt -sha256
            openssl genrsa -out ./demoCA/fqdn.key 2048
            openssl req -new \
                -key ./demoCA/fqdn.key \
                -out ./demoCA/fqdn.csr \
                -subj "/C=JP/ST=Tokyo/L=Tokyo/O=Asaichi/CN=${1}" \
                -sha256
            yes | openssl ca -md sha256 -config \
            <(cat ${CNF_PATH} \
            <( printf "\n[usr_cert]\nsubjectAltName=DNS:${1}, DNS:*.${1}")) \
            -keyfile ./demoCA/ca.key \
            -outdir ./ \
            -cert ./ca.crt \
            -in ./demoCA/fqdn.csr \
            -out ./demoCA/fqdn.crt -days 365
            cat ./demoCA/fqdn.crt > ./tls/fqdn.crt
            cat ./demoCA/fqdn.key >> ./tls/fqdn.crt
            rm 01.pem
            rm -rf ./demoCA
            break
        elif [ $yn = "n" ]; then
            break
        fi

        echo "Please enter y or n."
    done
}

function add_keychain() {
    echo "-----------------------------------------------"
    echo "独自に発行したルート証明書をキーチェーンに登録しますか？ [y/n]"
    echo "Do you want to register the created root certificate in the keychain? [y/n]"

    while read -p "" yn ; do
        expr "$yn" >/dev/null 2>&1

        if [ $? -ge 1 ]; then
            echo "Please enter y or n."
            continue
        elif [ $yn = "y" ]; then
            cd $1
            #echo "独自に発行した認証局のルート証明書を登録するためにMacのパスワードを入力してください。"
            sudo security delete-certificate -c "$2" > /dev/null
            echo ""
            sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ca.crt
            break
        elif [ $yn = "n" ]; then
            break
        fi

        echo "Please enter y or n."
    done
}

function add_hosts() {
    echo "-----------------------------------------------"
    echo "'127.0.0.1 ${1}' を /etc/hosts へ追加しますか？ [y/n]"
    echo "Do you want to add '127.0.0.1 ${1}' to /etc/hosts? [y/n]"

    while read -p "" yn ; do
        expr "$yn" >/dev/null 2>&1

        if [ $? -ge 1 ]; then
            echo "Please enter y or n."
            continue
        elif [ $yn = "y" ]; then
            sudo sh -c "echo '127.0.0.1 ${1}' >> /etc/hosts"
            break
        elif [ $yn = "n" ]; then
            break
        fi

        echo "Please enter y or n."
    done
}

function create_config() {
    echo "-----------------------------------------------"
    echo "haproxy.cfgを作成しますか？ [y/n]"
    echo "Do you want to create haproxy.cfg? [y/n]"

    while read -p "" yn ; do
        expr "$yn" >/dev/null 2>&1

        if [ $? -ge 1 ]; then
            echo "Please enter y or n."
            continue
        elif [ $yn = "y" ]; then
            cat haproxy.cfg.org | sed "s/##FQDN##/${1}/g" > haproxy.cfg
            break
        elif [ $yn = "n" ]; then
            break
        fi

        echo "Please enter y or n."
    done
}

confirm_domain "$FQDN"
create_certificate "$FQDN" "$SCRIPT_DIR" "$ROOT_CN" "$OS"

if [ "$OS" == 'Mac' ]; then
    add_keychain "$SCRIPT_DIR" "$ROOT_CN"
fi

add_hosts "$FQDN"
create_config "$FQDN"
