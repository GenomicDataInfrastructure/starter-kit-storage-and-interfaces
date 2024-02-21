#!/bin/sh

C4GH_VERSION="1.7.3"

apt-get -o DPkg::Lock::Timeout=60 update >/dev/null
apt-get -o DPkg::Lock::Timeout=60 install -y curl jq postgresql-client openssl >/dev/null

for n in download finalize inbox ingest mapper sync verify; do
    echo "creating credentials for: $n"
    ## password and permissions for MQ
    body_data=$(jq -n -c --arg password "$n" --arg tags none '$ARGS.named')
    curl -s -u test:test -X PUT "http://rabbitmq:15672/api/users/$n" -H "content-type:application/json" -d "${body_data}"
    curl -s -u test:test -X PUT "http://rabbitmq:15672/api/permissions/gdi/$n" -H "content-type:application/json" -d '{"configure":"","write":"sda","read":".*"}'

    ## password and permissions for DB
    if [ "$n" = inbox ]; then
        psql -U postgres -h postgres -d lega -c "CREATE ROLE inbox;"
        psql -U postgres -h postgres -d lega -c "GRANT base, ingest TO inbox;"
    fi

    if [ "$n" = ingest ]; then
        psql -U postgres -h postgres -d lega -c "GRANT UPDATE ON local_ega.main TO ingest;"
    fi

    psql -U postgres -h postgres -d lega -c "ALTER ROLE $n LOGIN PASSWORD '$n';"
done

# create EC256 key for signing the JWT tokens
mkdir -p /shared/keys/pub
if [ ! -f "/shared/keys/jwt.key" ]; then
    openssl ecparam -genkey -name prime256v1 -noout -out /shared/keys/jwt.key
    openssl ec -in /shared/keys/jwt.key -outform PEM -pubout >/shared/keys/pub/jwt.pub
    chmod 644 /shared/keys/pub/jwt.pub /shared/keys/jwt.key
fi

token="$(bash /scripts/sign_jwt.sh ES256 /shared/keys/jwt.key)"

cat >/shared/s3cfg <<EOD
[default]
access_key=dummy_gdi.eu
secret_key=dummy_gdi.eu
access_token=$token
check_ssl_certificate = False
check_ssl_hostname = False
encoding = UTF-8
encrypt = False
guess_mime_type = True
host_base = s3inbox:8000
host_bucket = s3inbox:8000
human_readable_sizes = true
multipart_chunk_size_mb = 50
use_https = False
socket_timeout = 30
EOD

## create crypt4gh key
## TODO: remove the cp lines and uncomment the crypt4gh generate line before merging
if [ ! -f "/shared/c4gh.sec.pem" ]; then
    curl -s -L https://github.com/neicnordic/crypt4gh/releases/download/v"${C4GH_VERSION}"/crypt4gh_linux_x86_64.tar.gz | tar -xz -C /shared/ && chmod +x /shared/crypt4gh
#    /shared/crypt4gh generate -n /shared/c4gh -p c4ghpass
fi
cp /scripts/c4gh.sec.pem /shared/c4gh.sec.pem
cp /scripts/c4gh.pub.pem /shared/c4gh.pub.pem

## create TLS certificates
bash /scripts/certs/make_certs.sh
