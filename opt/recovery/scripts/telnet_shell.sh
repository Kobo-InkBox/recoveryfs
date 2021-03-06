#!/bin/sh

mkdir -p /dev/pts
mount -t devpts devpts /dev/pts

IP=$(cat /boot/flags/USBNET_IP 2>/dev/null)
DEVICE=$(cat /opt/inkbox_device)

if [ "${DEVICE}" != "n873" ] && [ "${DEVICE}" != "n236" ] && [ "${DEVICE}" != "n437" ] && [ "${DEVICE}" != "n306" ] && [ "${DEVICE}" != "emu" ] && [ "${DEVICE}" != "bpi" ] && [ "${DEVICE}" != "kt" ]; then
	insmod "/modules/arcotg_udc.ko"
fi
if [ "${DEVICE}" == "n705" ] || [ "${DEVICE}" == "n905b" ] || [ "${DEVICE}" == "n905c" ] || [ "${DEVICE}" == "n613" ] || [ "${DEVICE}" == "n236" ] || [ "${DEVICE}" == "n437" ]; then
	insmod "/modules/g_ether.ko"
elif [ "${DEVICE}" == "n306" ] || [ "${DEVICE}" == "n873" ] || [ "${DEVICE}" == "bpi" ]; then
	insmod "/modules/fs/configfs/configfs.ko"
	insmod "/modules/drivers/usb/gadget/libcomposite.ko"
	insmod "/modules/drivers/usb/gadget/function/u_ether.ko"
	insmod "/modules/drivers/usb/gadget/function/usb_f_ecm.ko"
	[ -e "/modules/drivers/usb/gadget/function/usb_f_eem.ko" ] && insmod "/modules/drivers/usb/gadget/function/usb_f_eem.ko"
	insmod "/modules/drivers/usb/gadget/function/usb_f_ecm_subset.ko"
	insmod "/modules/drivers/usb/gadget/function/usb_f_rndis.ko"
	insmod "/modules/drivers/usb/gadget/legacy/g_ether.ko"
elif [ "${DEVICE}" == "kt" ]; then
	modprobe g_ether
else
	insmod "/modules/g_ether.ko"
fi

ifconfig usb0 up
if [ ! -z "${IP}" ]; then
	ifconfig usb0 "${IP}"
	if [ ${?} != 0 ]; then
		ifconfig usb0 192.168.2.2
	fi
else
	ifconfig usb0 192.168.2.2
fi

busybox-initrd telnetd -F &
