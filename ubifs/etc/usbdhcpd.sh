#!/bin/sh

# This file is part of MADDE
#
# Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
#
# Contact: Juha Riihimäki <juha.riihimaki@nokia.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public License
# version 2.1 as published by the Free Software Foundation.
#
# This library is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA

# Input parameters:
#	<ip-address>:	start dhcpd (dnsmasq) to provide given ip addres
#	add:		(from dnsmasq) restart dnsmasq
#	stop:		(from gui tool) stop dnsmasq

set -eu
#exec 2>> /tmp/maddev-usbdhcpd.log; date >&2; pwd >&2; set -x; : ::: "$@"

LC_ALL=C LANG=C
export LC_ALL LANG

PATH=/bin:/sbin:/usr/bin:/usr/sbin
export PATH

rundnsmasq ()
{
	/usr/sbin/dnsmasq -z -R -i usb0 -I lo -h -5 -p 0 \
		-F $_IP_ADDRESS,$_IP_ADDRESS,9999h -C /dev/null \
		--dhcp-option=6 --dhcp-option=3 \
		-9 -6 $_USB0_DHCP_SCRIPT -x /var/run/dnsmasq-maddev.pid
}

killdnsmasq0 ()
{
	test -f /var/run/dnsmasq-maddev.pid || return 0
	killdnsmasq
}

killdnsmasq ()
{
	trap '' HUP TERM INT QUIT
	pid=`cat /var/run/dnsmasq-maddev.pid || :`
	case $pid in '') return 0 ;; esac
	fgrep -q _USB0_DHCP_SCRIPT= /proc/$pid/environ 2>/dev/null &&
		kill $pid || :
	sleep 1
}

# 'add' comes from dnsmasq. in that case restart it...
case ${1:-} in
	add)	killdnsmasq
		rundnsmasq
		;;
	stop)	killdnsmasq0
		;;
	[1-9]*.*[0-9].[0-9]*.*[0-9])
		_IP_ADDRESS=$1
		case $0 in
			/*) _USB0_DHCP_SCRIPT=$0 ;;
			*/*) _USB0_DHCP_SCRIPT=`cd ${0%/*}; pwd`/${0##*/} ;;
			*) _USB0_DHCP_SCRIPT=`pwd`/$0 ;;
		esac
		export _IP_ADDRESS _USB0_DHCP_SCRIPT
		killdnsmasq0
		rundnsmasq
		;;
	'')
		case ${_IP_ADDRESS:-} in [1-9]*) exit 0 ;; esac
		exec 2>&1
		echo
		echo Usage: $0 '<ip-address>|'stop
		echo
		echo '  ' ip-address: provide given ip-address to dhcp queries
		echo '  ' stop: stop dhcp '(dnsmasq)' server
		echo
		exit 1
		;;
esac

# Local variables:
# mode: shell-script
# sh-basic-offset: 8
# tab-width: 8
# End:
# vi: set sw=8 ts=8
