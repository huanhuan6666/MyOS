%.bin: %.asm
	nasm $< -o $@

master.img: boot.bin
	yes | bximage -hd -mode="flat" -size=16 -q master.img
	dd if=$< of=$@ bs=512 count=1 conv=notrunc

.PHONY: bochs
bochs:master.img
	bochs -q

.PHONY:clean
clean:
	rm -rf master.img
	rm -rf *.bin%      