#!/bin/bash
#
# enable-sshd-hmac-sha1-for-jenkins-slaves.sh by <ebo@>
#
# Jenkins SSH (Java SSH) does not support the MACs that are configured by default in sshd on RHEL/CentOS 7.
#
# This script adds 'hmac-sha1' to '/etc/ssh/sshd_config' and restarts 'sshd'.
#
# Usage:
# sudo ./enable-sshd-hmac-sha1-for-jenkins-slaves.sh

set -ueo pipefail

readonly __progname="$(basename "$0")"

errx() {
	echo -e "${__progname}: $*" >&2

	exit 1
}

main() {
	[ "${EUID}" -ne 0 ] && \
		errx "need root"

	for bin in sshd systemctl; do
		which "${bin}" >/dev/null 2>&1 || \
			errx "cannot find '${bin}' in 'PATH=${PATH}'"
	done

	local -r service="sshd"
	local -r sshdconf="/etc/ssh/sshd_config"

	echo "updating: '${sshdconf}' to provide hmac-sha1 MAC"
	sed -i 's/hmac-sha2-256/hmac-sha2-256,hmac-sha1/' "${sshdconf}"
	sshd -t || \
		errx "sshd configuration check failed"

	echo "restarting: '${service}'"
	systemctl restart "${service}" || \
		errx "systemctl restart '${service}' failed"

	return 0
}

main "$@"

exit $?
