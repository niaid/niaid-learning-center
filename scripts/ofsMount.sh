#!/bin/bash

# PARAMETER PARSING
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -l|--license)
    export OBJECTIVEFS_LICENSE="$2"
    shift # past argument
    shift # past value
    ;;
    -r|--region)
    export AWS_DEFAULT_REGION="$2"
    shift # past argument
    shift # past value
    ;;
    -p|--passphrase)
    export OBJECTIVEFS_PASSPHRASE="$2"
    shift # past argument
    shift # past value
    ;;
    -a|--account)
    export OFS_DEV_ACCT="$2"
    shift # past argument
    ;;
    -w|--app)
    export APP="$2"
    shift # past argument
    ;;
    -s|--stack)
    export STACK="$2"
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# ENV VARS
export OBJECTIVEFS_ENV="/etc/objectivefs/nlc"
export OFS_CORE_DATA_DIR="/mnt/ofs-data"
export OFS_STACK_DATA_DIR="/mnt/${APP}/${STACK}"
export DISKCACHE_PATH="/var/cache/objectivefs"

# INSTALL / CONFIG
yum install -y nfs-utils bash curl which jq
yum install -y https://s3.amazonaws.com/pubfiles-coreinfra-0d49b49f3ba3/objectivefs/objectivefs-6.4-1.rpm
mkdir -p ${OBJECTIVEFS_ENV} ${OFS_CORE_DATA_DIR} ${OFS_STACK_DATA_DIR} ${DISCKCACHE_PATH}
chmod 700 ${OBJECTIVEFS_ENV}
chmod -R 777 ${OFS_CORE_DATA_DIR} /mnt/${APP} ${DISCKCACHE_PATH}
chown -R 101:102 /mnt/${APP}
echo ${OBJECTIVEFS_LICENSE} > ${OBJECTIVEFS_ENV}/OBJECTIVEFS_LICENSE
echo ${AWS_DEFAULT_REGION} > ${OBJECTIVEFS_ENV}/AWS_DEFAULT_REGION
echo ${OBJECTIVEFS_PASSPHRASE} > ${OBJECTIVEFS_ENV}/OBJECTIVEFS_PASSPHRASE

# prepare OFS DISKCACHE
mkfs -t xfs /dev/nvme1n1
mount /dev/nvme1n1 ${DISKCACHE_PATH}

# Get creds & mount OFS mount
aws sts assume-role --role-arn arn:aws:iam::${OFS_DEV_ACCT}:role/dlp-ofs-access --role-session-name dlp-ofs-dev --duration-seconds 43200 --query "Credentials" > tmpCreds
export AWS_ACCESS_KEY_ID=$(jq -r '.AccessKeyId' tmpCreds)
export AWS_SECRET_ACCESS_KEY=$(jq -r '.SecretAccessKey' tmpCreds)
export AWS_SESSION_TOKEN=$(jq -r '.SessionToken' tmpCreds)
export AWS_SECURITY_TOKEN=$(jq -r '.SessionToken' tmpCreds)
unlink tmpCreds
DISKCACHE_SIZE=1P:20G CACHESIZE=50% /sbin/mount.objectivefs -o mt s3://ofs-pool-niaid-dev-dev/dlp ${OFS_CORE_DATA_DIR}

# create sub-mount for current stack
for d in ${OFS_CORE_DATA_DIR}/*
do
   ln -s "$d" "${OFS_STACK_DATA_DIR}/"
done
rm -f ${OFS_STACK_DATA_DIR}/cache ${OFS_STACK_DATA_DIR}/localcache \
${OFS_STACK_DATA_DIR}/muc ${OFS_STACK_DATA_DIR}/temp \
${OFS_STACK_DATA_DIR}/trashdir
