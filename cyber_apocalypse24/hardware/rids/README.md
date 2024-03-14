# Cyber Apocalypse 2024

## Rids

> Upon reaching the factory door, you physically open the RFID lock and find a flash memory chip inside. The chip's package has the word W25Q128 written on it. Your task is to uncover the secret encryption keys stored within so the team can generate valid credentials to gain access to the facility.
> 
> Author: n/a
> 
> [`hardware_rids.zip`](hardware_rids.zip)

Tags: _hardware_

## Solution
This challenge gives us a python script.

```python
import socket
import json

def exchange(hex_list, value=0):

    # Configure according to your setup
    host = '127.0.0.1'  # The server's hostname or IP address
    port = 1337        # The port used by the server
    cs=0 # /CS on A*BUS3 (range: A*BUS3 to A*BUS7)
    
    usb_device_url = 'ftdi://ftdi:2232h/1'

    # Convert hex list to strings and prepare the command data
    command_data = {
        "tool": "pyftdi",
        "cs_pin":  cs,
        "url":  usb_device_url,
        "data_out": [hex(x) for x in hex_list],  # Convert hex numbers to hex strings
        "readlen": value
    }
    
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((host, port))
        
        # Serialize data to JSON and send
        s.sendall(json.dumps(command_data).encode('utf-8'))
        
        # Receive and process response
        data = b''
        while True:
            data += s.recv(1024)
            if data.endswith(b']'):
                break
                
        response = json.loads(data.decode('utf-8'))
        #print(f"Received: {response}")
    return response


# Example command
jedec_id = exchange([0x9F], 3)
print(jedec_id)
```

From the challenge description we can assume the client is communicating with a `W25Q128` flash memory. So, basically the API to programm the flash memory. We can find a [`documentation`](https://docs.rs-online.com/9bfc/0900766b81704060.pdf) for a similar device and can see the command `0x9F` reads the `JEDEC ID` of the memory (thats also what the code suggests, so we are hopefully on the right way).

Another interesting method is reading the flash memory, which is command `0x03`.

> The Read Data instruction allows one or more data bytes to be sequentially read from the memory. The
> instruction is initiated by driving the /CS pin low and then shifting the instruction code “03h” followed by a
> 24-bit address (A23-A0) into the DI pin. The code and address bits are latched on the rising edge of the
> CLK pin. After the address is received, the data byte of the addressed memory location will be shifted out
> on the DO pin at the falling edge of CLK with most significant bit (MSB) first. The address is automatically
> incremented to the next higher address after each byte of data is shifted out allowing for a continuous
> stream of data. This means that the entire memory can be accessed with a single instruction as long as
> the clock continues. The instruction is completed by driving /CS high.

So, why we don't try this out? And indeed, this gives us the flag.

```python
data = exchange([0x03], 100)
for i in data:
    print(chr(i), end="")
```

Flag `HTB{m3m02135_57023_53c2375_f02_3v32y0n3_70_533!@}`