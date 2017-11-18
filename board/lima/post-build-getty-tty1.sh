#!/bin/sh

# Add a getty on tty1 so that users can login on the display using a keyboard.
if ! grep -q 'GETTY_TTY1' "$TARGET_DIR/etc/inittab"
then
	echo 'tty1::respawn:/sbin/getty -L  tty1 0 vt100 # GETTY_TTY1' >> "$TARGET_DIR/etc/inittab"
fi
