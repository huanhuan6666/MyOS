%.bin: %.asm
	nasm $< -o $@

master.img: boot.bin
	yes | bximage -hd -mode="flat" -size=16 -q master.img
	dd if=$< of=$@ bs=512 count=1 conv=notrunc

.PHONY: bochs
bochs:master.img
	bochs -q

.PHONY: usb
usb: boot.bin /dev/sdb
	sudo dd if=/dev/sdb of=tmp.bin bs=512 count=1 conv=notrunc
	cp tmp.bin usb.bin
	sudo rm tmp.bin
	dd if=boot.bin of=usb.bin bs=446 count=1 conv=notrunc
	sudo dd if=usb.bin of=/dev/sdb bs=512 count=1 conv=notrunc
	rm usb.bin
.PHONY:clean
clean:
	rm -rf master.img
	rm -rf *.bin%      