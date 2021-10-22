obj-m = xpad.o

MOK_KEY_DIR ?= /var/lib/shim-signed/mok

KVERSION ?= $(shell uname -r)
MODDESTDIR := /lib/modules/$(KVERSION)/kernel/drivers/input/joystick

.PHONY: all clean sign install

all:
	make -C /lib/modules/$(KVERSION)/build V=1 M=$(PWD) modules
debug:
	make -C -DDEBUG_VERBOSE /lib/modules/$(KVERSION)/build V=1 M=$(PWD) modules
clean:
	git clean -x -f
	# test ! -d /lib/modules/$(KVERSION) || make -C /lib/modules/$(KVERSION)/build V=1 M=$(PWD) clean
sign: all
	sudo kmodsign sha512 $(MOK_KEY_DIR)/MOK.priv $(MOK_KEY_DIR)/MOK.der xpad.ko
install: sign
	sudo rm -f $(MODDESTDIR)/xpad.ko
	sudo mkdir -p $(MODDESTDIR)
	sudo install -p -D -m 644 xpad.ko $(MODDESTDIR)
restart: install
	sudo modprobe -r xpad
	sudo modprobe xpad
renew: clean restart
