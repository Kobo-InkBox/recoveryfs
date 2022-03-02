#!/bin/sh

DO_FACTORY_RESET=$(cat /boot/flags/DO_FACTORY_RESET 2>/dev/null)
DO_SOFT_RESET=$(cat /boot/flags/DO_SOFT_RESET 2>/dev/null)
DEVICE=$(cat /opt/device)

if [ "${DEVICE}" == "n705" ] || [ "${DEVICE}" == "n905b" ] || [ "${DEVICE}" == "n905c" ]; then
	DPI=187
elif [ "${DEVICE}" == "n613" ] || [ "${DEVICE}" == "n236" ] || [ "${DEVICE}" == "n306" ]; then
	DPI=215
elif [ "${DEVICE}" == "n437" ]; then
	DPI=275
else
	DPI=187
fi

if [ "${DO_FACTORY_RESET}" == "true" ]; then
	# Restoring standard size, 512 MiB onboard storage
	/opt/recovery/scripts/restore.sh 512
elif [ "${DO_SOFT_RESET}" == "true" ]; then
	# Wipe onboard storage, but keep current firmware version
	/opt/recovery/scripts/soft-reset.sh
else
	if [ "${DEVICE}" == "n705" ] || [ "${DEVICE}" == "n905b" ] || [ "${DEVICE}" == "n905c" ] || [ "${DEVICE}" == "n613" ]; then
		FB_UR=3
		echo 0 > "/sys/class/leds/pmic_ledsb/brightness"
	elif [ "${DEVICE}" == "n306" ]; then
		FB_UR=3
		echo 1 > "/sys/devices/platform/leds/leds/GLED" ; echo 0 > "/sys/devices/platform/leds/leds/GLED"
	elif [ "${DEVICE}" == "bpi" ]; then
		FB_UR=0
		echo 0 > "/sys/devices/platform/leds/leds/bpi:red:pwr/brightness"
	elif [ "${DEVICE}" == "n236" ] || [ "${DEVICE}" == "n437" ]; then
		FB_UR=3
		/opt/bin/shutdown_led
	else
		FB_UR=0
		echo 0 > /sys/class/leds/pmic_ledsb/brightness
	fi
	echo ${FB_UR} > /sys/class/graphics/fb0/rotate

	cd /opt/recovery
	QT_FONT_DPI=${DPI} QTPATH=/opt/qt-linux-5.15.2-kobo/  LD_LIBRARY_PATH="${QTPATH}lib:lib:" QT_QPA_PLATFORM=kobo ./inkbox-recovery
fi
