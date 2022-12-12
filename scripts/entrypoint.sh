#!/bin/bash

set +x

trap 'stop' SIGINT

debug_output() {
echo "PHP VER: $PHP_VER"
echo "APACHE2 DIR: $APACHE2_HTML_DIRECTORY"
echo "APACHE2 SITE DIR: $APACHE2_SITES_CONF_DIR"
echo "STARTUP SCRIPT DIR: $STARTUP_SCRIPTS_DIRECTORY"
echo "APACHE2 WEB ROOT: $APACHE2_WEB_ROOT"
echo "S3 BUCKET: $S3_SYNC_BUCKET"
}

# start apache2
/run-httpd.sh &

# install moodle plugins
# /bin/sh /opt/startup_scripts/installplugins.sh

debug_output

# create email template
# /bin/sh /opt/startup_scripts/enable-html-email.sh &> /dev/null

# modify theme template
# /bin/sh /opt/startup_scripts/theme-template.sh &> /dev/null

# Initial cron run
/usr/bin/php $APACHE_HTML_DIRECTORY/moodle/admin/cli/cron.php &> /dev/null

# if [[ -z ${DEV_EMAIL} ]]; then
  # monarch ENV populates SMTP on deploy
  # mysql -u $DB_USER --password=$DB_PASS -h $DB_HOST $DB_NAME -e " UPDATE mdl_config SET value = '"$SES_SMTP_HOST":587' WHERE name = 'smtphosts' "
  # mysql -u $DB_USER --password=$DB_PASS -h $DB_HOST $DB_NAME -e " UPDATE mdl_config SET value = 'tls' WHERE name = 'smtpsecure' "
  # mysql -u $DB_USER --password=$DB_PASS -h $DB_HOST $DB_NAME -e " UPDATE mdl_config SET value = '"$SES_SMTP_USER"' WHERE name = 'smtpuser' "
  # mysql -u $DB_USER --password=$DB_PASS -h $DB_HOST $DB_NAME -e " UPDATE mdl_config SET value = '"$SES_SMTP_PASSWORD"' WHERE name = 'smtppass' "
  # mysql -u $DB_USER --password=$DB_PASS -h $DB_HOST $DB_NAME -e " UPDATE mdl_config SET value = 'LOGIN' WHERE name = 'smtpauthtype' "
  # mysql -u $DB_USER --password=$DB_PASS -h $DB_HOST $DB_NAME -e " UPDATE mdl_config SET value = 'mail.nih.gov' WHERE name = 'allowedemaildomains' "
  # mysql -u $DB_USER --password=$DB_PASS -h $DB_HOST $DB_NAME -e " UPDATE mdl_config SET value = 'support-daidslearningportal@mail.nih.gov' WHERE name = 'noreplyaddress' "
# fi

stop(){
  echo "[$(date +'%Y-%d-%m %H:%M:%S')] [entrypoint.sh] STOPPED - Stopping application..."
  exit 0
}


# run indefinitely, until error, or SIGINT
#
while true
do
  sleep 1m
  /usr/bin/php /var/www/html/moodle/admin/cli/cron.php &> /dev/null
done


