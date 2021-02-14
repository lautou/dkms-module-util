#!/bin/bash -
### NAME
###     sign_module.sh
###
### SYNOPSIS
###     sign_module.sh [options]
###
### DESCRIPTION
###
### REQUIREMENTS
###
### AUTHOR
###     Ding-Yi Chen (definite), dingyichen@gmail.com
###     Created in 2019-02-26 11:01:11
###
set -eu         # Exit when returns non-zero, Error when variable is unset.
echo Running kernel module signature script...
KVER=$1
LOGGER_TAG=dkms-sign
: ${SIGN_CONFIG:=/root/.config/dkms-sign.conf}
if [[ -z $KVER ]]; then
    logger -s -t $LOGGER_TAG "WARN: Kernel version argument is missing, no signing"
    exit 0
fi
if [[ ! -r $SIGN_CONFIG ]];then
    logger -s -t $LOGGER_TAG "WARN: SIGN_CONFIG file $SIGN_CONFIG not found, no signing"
    exit 0
fi
source $SIGN_CONFIG
if [[ -z $KEY_DIR ]];then
    logger -s -t $LOGGER_TAG "WARN: KEY_DIR is not defined in $SIGN_CONFIG, no signing"
    exit 0
fi
MODULE_NAME=$(sed -n -e '/PACKAGE_NAME=/ s/.*=//p' dkms.conf | tr -d '"')
BUILT_MODULE_NAME=$(sed -n -e '/BUILT_MODULE_NAME\[0\]=/ s/.*=//p' dkms.conf | tr -d '"')
: ${PACKAGE_VERSION:=$(sed -n -e '/PACKAGE_VERSION=/ s/.*=//p' dkms.conf | tr -d '"')}
: ${KERNEL_RELEASE:=$KVER}
: ${KO_FILE:=/var/lib/dkms/$MODULE_NAME/$PACKAGE_VERSION/$KERNEL_RELEASE/x86_64/module/$BUILT_MODULE_NAME.ko}
echo MODULE_NAME=$MODULE_NAME
echo BUILT_MODULE_NAME=$BUILT_MODULE_NAME
echo PACKAGE_VERSION=$PACKAGE_VERSION
echo KERNEL_RELEASE=$KERNEL_RELEASE
echo KO_FILE=$KO_FILE
xz -d $KO_FILE.xz
/usr/src/kernels/$KERNEL_RELEASE/scripts/sign-file sha256 $KEY_DIR/MOK.priv $KEY_DIR/MOK.der $KO_FILE
xz -z $KO_FILE
