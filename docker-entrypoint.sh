#!/bin/sh
cd /var/www/html
sed -i -e 's|DB_CONNECTION=mysql|DB_CONNECTION='${TRIX_DB_CONNECTION}'|g' .env
sed -i -e 's|DB_HOST="localhost"|DB_HOST="'${TRIX_DB_HOST}'"|g' .env
sed -i -e 's|DB_PORT=3306|DB_PORT='${TRIX_DB_PORT}'|g' .env
sed -i -e 's|DB_DATABASE="trixcms"|DB_DATABASE="'${TRIX_DB_DATABASE}'"|g' .env
sed -i -e 's|DB_USERNAME="root"|DB_USERNAME="'${TRIX_DB_USERNAME}'"|g' .env
sed -i -e 's|DB_PASSWORD=""|DB_PASSWORD="'${TRIX_DB_PASSWORD}'"|g' .env

sed -i -e 's|APP_LANG=""|'${TRIX_APP_LANG}'"|g' .env
sed -i -e 's|APP_URL=http://localhost|APP_URL='${TRIX_APP_URL}'|g' .env
sed -i -e 's|APP_MAINTENANCE="1"|APP_MAINTENANCE="'${TRIX_APP_MAINTENANCE}'"|g' .env

sed -i -e 's|MAIL_DRIVER="smtp"|MAIL_DRIVER="'${TRIX_MAIL_DRIVER}'"|g' .env
sed -i -e 's|MAIL_HOST="smtp.trixcms.eu"|MAIL_HOST="'${TRIX_MAIL_HOST}'"|g' .env
sed -i -e 's|MAIL_PORT="587"|MAIL_PORT="'${TRIX_MAIL_PORT}'"|g' .env
sed -i -e 's|MAIL_USERNAME="no-reply@trixcms.eu"|MAIL_USERNAME="'${TRIX_MAIL_USERNAME}'"|g' .env
sed -i -e 's|MAIL_PASSWORD=""|MAIL_PASSWORD="'${TRIX_MAIL_PASSWORD}'"|g' .env
sed -i -e 's|MAIL_ENCRYPTION="tls"|MAIL_ENCRYPTION="'${TRIX_MAIL_ENCRYPTION}'"|g' .env
sed -i -e 's|MAIL_FROM_ADDRESS=""|MAIL_FROM_ADDRESS="'${TRIX_MAIL_FROM_ADDRESS}'"|g' .env
sed -i -e 's|MAIL_FROM_NAME=""|MAIL_FROM_NAME="'${TRIX_MAIL_FROM_NAME}'"|g' .env

sed -i -e 's|MODULE_PAYMENT="true"|MODULE_PAYMENT="'${TRIX_MODULE_PAYMENT}'"|g' .env
sed -i -e 's|MODULE_AUTH="true"|MODULE_AUTH="'${TRIX_MODULE_AUTH}'"|g' .env
/testdb.sh
if [ $? -ne 0 ]
then
  exit 1
fi
/usr/bin/php artisan migrate --force
/usr/sbin/httpd -D FOREGROUND

