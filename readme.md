
# Shellcode testing program


## Usage

    sct {-f file | $'\xeb\xfe' | '\xb8\x39\x05\x00\x00\xc3'}


## Examples

```bash
$ sct $'\xeb\xfe'                 # raw shellcode
$ sct '\xb8\x39\x05\x00\x00\xc3'  # escaped shellcode
$ sct -f test.sc                  # shellcode from file
$ sct -f <(python gen_payload.py) # test generated payload
$ sct -s 5 -f test.sc             # create socket at fd=5
# Allows to test staged shellcodes
# Flow is redirected like this: STDIN -> SOCKET -> STDOUT
```

## Author

hellman (hellman1908@gmail.com), zTrix (i@ztrix.me)
