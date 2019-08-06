#!/bin/bash
LINUX_DIR=$1
: ${LINUX_DIR:=`readlink -f linux-hikalium`}

echo ${LINUX_DIR}

function print_config_state {
	CONFIG_NAME=$1
	echo "`${LINUX_DIR}/scripts/config --file ${LINUX_DIR}/.config -s ${CONFIG_NAME}` ${CONFIG_NAME}"
}

function y {
	CONFIG_NAME=$1
	print_config_state ${CONFIG_NAME}
}
function n {
	CONFIG_NAME=$1
	print_config_state ${CONFIG_NAME}
}
function m {
	CONFIG_NAME=$1
	print_config_state ${CONFIG_NAME}
}

source config_for_ndckpt.txt
