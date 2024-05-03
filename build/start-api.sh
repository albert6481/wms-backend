#!/bin/bash

APP_NAME=wms_project

cd /srv/wms_project/

if [ $WMS_MIGRATE_DB -eq 1 ]
then
    echo "Starting db migration"

    python3 manage.py migrate -v 3
    MIGRATION_RET=$?
    if [ $MIGRATION_RET -ne 0 ]; then
        echo "Failed db migration"
        exit 1
    fi
else
    echo "Not going to migrate db"
fi

if [ $WMS_COLLECT_STATIC -eq 1 ]
then
    echo "Collecting static files"
    python3 manage.py collectstatic --no-input
    COLLECT_STATIC_RET=$?
    if [ $COLLECT_STATIC_RET -ne 0 ]; then
        echo "Collecting static files"
        exit 1
    fi
else
    echo "Not going to collect static"
fi

if [ ! -f "/srv/$APP_NAME/uwsgi.ini" ]
then
    sed -e "s/:api_threads:/$API_THREADS/g" \
        -e "s/:api_processes:/$API_PROCESSES/g" \
        "/srv/$APP_NAME/uwsgi.sample.ini" > "/srv/$APP_NAME/uwsgi.ini"
fi


# NEWRELIC_POSTFIX=$WMS_ENVIRONMENT

# if [[ -z "${APP_SUB_NAME}" ]]
# then
#     NEWRELIC_POSTFIX=$WMS_ENVIRONMENT
# else
#     NEWRELIC_POSTFIX=$APP_SUB_NAME"-"$WMS_ENVIRONMENT
# fi

# if [ ! -f "/srv/wms_project/newrelic.ini" ]
# then
#     sed -e "s/:key:/$NEWRELIC_LICENSE_KEY/g" \
#         -e "s/:env:/$NEWRELIC_POSTFIX/g" \
#         /srv/wms_project/newrelic.sample.ini > /srv/wms_project/newrelic.ini
# fi


exec uwsgi --hook-master-start "unix_signal:15 gracefully_kill_them_all" --ini "/srv/$APP_NAME/uwsgi.ini" --touch-reload "/srv/$APP_NAME/uwsgi.ini"
