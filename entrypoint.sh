#!/bin/bash
sleep 1

cd /home/container

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
${MODIFIED_STARTUP}

set -e
role=${CONTAINER_ROLE:-app}
env=${APP_ENV:-production}
if [ "$role" = "queue" ]; then
    echo "Running the queue..."
    php /home/container/webroot/artisan queue:work --verbose --tries=3 --timeout=90
elif [ "$role" = "scheduler" ]; then
    while [ true ]
    do
      php /home/container/webroot/artisan schedule:run --verbose --no-interaction &
      sleep 60
    done
else
    echo "Could not match the container role \"$role\""
    exit 1
fi