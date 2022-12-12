export ROOT_PW=localDev
export DB_NAME=moodle
export DB_USER=moodle
export DB_HOST=nlc_localhost
export APP_CONTAINER=niaid-learning-center

export DB_FILE_LOCATION=mariadb-data

docker run --name ${DB_HOST} --rm --network moodle-network -v ${DB_FILE_LOCATION}:/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=${ROOT_PW} \
-e MYSQL_DATABASE=${DB_NAME} \
-e MYSQL_USER=${DB_USER} \
-d mariadb 

docker build -t ${APP_CONTAINER} ../.

docker run --network moodle-network --name ${APP_CONTAINER} --rm \
-e DB_HOST=${DB_HOST} \
-e DB_NAME=${DB_NAME} \
-e DB_USER=${DB_USER} \
-e DB_PASS=${DB_PASS} \
-p 8889:8888 \
-d ${APP_CONTAINER}

