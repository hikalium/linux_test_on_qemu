#!/bin/bash
LINUX_DIR=$1
: ${LINUX_DIR:=`readlink -f linux-hikalium`}

echo ${LINUX_DIR}

function print_config_state {
	CONFIG_NAME=$1
	echo "${CONFIG_NAME} : `${LINUX_DIR}/scripts/config --file ${LINUX_DIR}/.config -s ${CONFIG_NAME}`"
}

function y {
	CONFIG_NAME=$1
	${LINUX_DIR}/scripts/config --file ${LINUX_DIR}/.config -e ${CONFIG_NAME}
	print_config_state ${CONFIG_NAME}
}
function m {
	CONFIG_NAME=$1
	${LINUX_DIR}/scripts/config --file ${LINUX_DIR}/.config -m ${CONFIG_NAME}
	print_config_state ${CONFIG_NAME}
}

source config_for_ndckpt.txt

cp -i ${LINUX_DIR}/.config kernel_config_v5.1.8.txt
