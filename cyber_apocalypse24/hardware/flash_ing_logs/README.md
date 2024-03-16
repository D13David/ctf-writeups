# Cyber Apocalypse 2024

## Flash-ing Logs

> After deactivating the lasers, you approach the door to the server room. It seems there's a secondary flash memory inside, storing the log data of every entry. As the system is air-gapped, you must modify the logs directly on the chip to avoid detection. Be careful to alter only the user_id = 0x5244 so the registered logs point out to a different user. The rest of the logs stored in the memory must remain as is.
> 
> Author: diogt
> 
> [`hardware_flashing-logs.zip`](hardware_flashing-logs.zip)

Tags: _hardware_

## Solution
For this challenge, we get again the `client` we already know from the [`Rids`](../rids/README.md) challenge. So its again the `W25Q128` flash memory. Reading the instruction, we are in a server room and the chip logs entry events to the server room. To hide our trail our challenge is to change the log entries of *our user id* to point to *another user id*.

Perfect, we already know how to read data, so we just dump the memory and see where data is written. The main part of the data is uninitialized but first `2560` bytes contain information, so we can guess this is the log record-set.

```python
def debug_print_data_raw(data):
    for i, b in enumerate(data):
        print(f"{b:02X}", end=" ")
        if (i+1)%16 == 0: print()
    print()

def flash_write_disable():
    res = exchange([0x04], 1)
    
def read_data(length, addr):
    flash_write_disable()

    cmd = [0] * 4
    cmd[0] = 0x03
    cmd[1] = (addr >> 16) & 0xff
    cmd[2] = (addr >> 8)  & 0xff
    cmd[3] = (addr >> 0)  & 0xff

    data = bytearray(exchange(cmd, length))

    return data

if __name__ == "__main__":
    debug_print_data_raw(read_data(1024*4, 0x0))
```

```
$ python client.py
87 74 D8 FC 23 5D C1 8B 6D 07 48 53 98 D4 5D 17
24 A0 D9 FC DF 5D 91 8A 6E 07 48 53 DB CD EE C3
37 B2 DE FC 4A 5D E2 89 6F 07 48 53 EB 4C E4 B9
F9 A8 DE FC 23 5D 46 8A 6E 07 48 53 77 2E 1D FE
AF 3D DE FC 4A 5D E2 89 6E 07 48 53 35 1E 92 8F
DA 36 DE FC 7A 5D EB 88 6F 07 48 53 F5 23 44 37
F5 CA DF FC DF 5D D5 8A 6F 07 48 53 BC 25 E7 97
A9 71 DF FC EC 5D D5 8A 6E 07 48 53 0D F8 C2 61
49 BA DC FC EC 5D 7D 8A 6E 07 48 53 51 78 A7 B5
06 7D DC FC 2D 5D C1 8B 6F 07 48 53 51 B3 1A 21
...
1A 1B 7F FF F0 5D BA DB 6D 07 48 53 CF 5B 6C 85
86 2D 7F FF 9D 5D BA DB 6F 07 48 53 EC 68 81 CD
DA CB 7C FF 9D 5D BA DB 6F 07 48 53 86 AD 47 D0
D6 A1 7C FF F0 5D BA DB 6F 07 48 53 D1 9B D8 2C
FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
...
```

Next up is to actually understand the data. For this the challenge gives us the routines which are used to write the data.

```c
#define KEY_SIZE 12 // Size of the key

// encrypts log events
void encrypt_data(uint8_t *data, size_t data_length, uint8_t register_number, uint32_t address) {
    uint8_t key[KEY_SIZE];

    read_security_register(register_number, 0x52, key); // register, address

    printf("Data before encryption (including CRC):\n");
    for(size_t i = 0; i < data_length; ++i) {
        printf("%02X ", data[i]);
    }
    printf("\n");

    // Print the CRC32 checksum before encryption (assuming the original data includes CRC)
    uint32_t crc_before_encryption = calculateCRC32(data, data_length - CRC_SIZE);
    printf("CRC32 before encryption: 0x%08X\n", crc_before_encryption);

    // Apply encryption to data, excluding CRC, using the key
    for (size_t i = 0; i < data_length - CRC_SIZE; ++i) { // Exclude CRC data from encryption
        data[i] ^= key[i % KEY_SIZE]; // Cycle through  key bytes
    }

    printf("Data after encryption (including CRC):\n");
    for(size_t i = 0; i < data_length; ++i) {
        printf("%02X ", data[i]);
    }
    printf("\n");


}

void write_to_flash(uint32_t sector, uint32_t address, uint8_t *data, size_t length) {
    printf("Writing to flash at sector %u, address %u\n", sector, address);

    uint8_t i;
    uint16_t n;

    encrypt_data(data, length, 1, address);

    n =  W25Q128_pageWrite(sector, address, data, 16);
    printf("page_write(0,10,d,26): n=%d\n",n);

}
```

We can see, data is written encrypted to a certain address. The encryption is a fairly easy xor encryption with a 12 byte wide key. Also every log entry ends with a crc32 value of the entry data, but the crc32 value is not encrypted. Interestingly, the key is read from a security register, so wie consult our [`documentation`](https://docs.rs-online.com/9bfc/0900766b81704060.pdf) about this.

> **Read Security Registers (48h)**
> The Read Security Register instruction is similar to the Fast Read instruction and allows one or more data
> bytes to be sequentially read from one of the three security registers. The instruction is initiated by driving
> the /CS pin low and then shifting the instruction code “48h” followed by a 24-bit address (A23-A0) and
> eight “dummy” clocks into the DI pin. The code and address bits are latched on the rising edge of the CLK
> pin. After the address is received, the data byte of the addressed memory location will be shifted out on
> the DO pin at the falling edge of CLK with most significant bit (MSB) first. The byte address is
> automatically incremented to the next byte address after each byte of data is shifted out. Once the byte
> address reaches the last byte of the register (byte address FFh), it will reset to address 00h, the first byte
> of the register, and continue to increment. The instruction is completed by driving /CS high. The Read
> Security Register instruction sequence is shown in Figure 46. If a Read Security Register instruction is
> issued while an Erase, Program or Write cycle is in process (BUSY=1) the instruction is ignored and will
> not have any effects on the current cycle. The Read Security Register instruction allows clock rates from
> D.C. to a maximum of FR (see AC Electrical Characteristics). 
>
> `Address                A23-16    A15-12      A11-8       A7-0`
> `Security Register #1   00h       0 0 0 1     0 0 0 0     Byte address`
> `Security Register #2   00h       0 0 1 0     0 0 0 0     Byte address`
> `Security Register #3   00h       0 0 1 1     0 0 0 0     Byte address`

All in all our command we need to send looks like this:

```python
def read_encryption_key():
    # 0x48    => Read Security Register
    # A32-16  => 0
    # A15-8   => 00010000 (16) register #1
    # A7-0    => address taken from log_event.c
    return bytearray(exchange([0x48, 0, 16, 0x52, 0, 0], 12))
```

This gives us the key, so we can now decrypt the data we read. But we still need to know how the log data is layed out in memory. This, we can again, read from log_event.c.

```c
// SmartLockEvent structure definition
typedef struct {
    uint32_t timestamp;   // Timestamp of the event
    uint8_t eventType;    // Numeric code for type of event // 0 to 255 (0xFF)
    uint16_t userId;      // Numeric user identifier // 0 t0 65535 (0xFFFF)
    uint8_t method;       // Numeric code for unlock method
    uint8_t status;       // Numeric code for status (success, failure)
} SmartLockEvent;

// Implementations
int log_event(const SmartLockEvent event, uint32_t sector, uint32_t address) {

    bool memory_verified = false;
    uint8_t i;
    uint16_t n;
    uint8_t buf[256];


    memory_verified = verify_flashMemory();
    if (!memory_verified) return 0;

     // Start Flash Memory
    W25Q128_begin(SPI_CHANNEL);


    // Erase data by Sector
    if (address == 0){
        printf("ERASE SECTOR!");
        n = W25Q128_eraseSector(0, true);
        printf("Erase Sector(0): n=%d\n",n);
        memset(buf,0,256);
        n =  W25Q128_read (0, buf, 256);

    }

    uint8_t buffer[sizeof(SmartLockEvent) + sizeof(uint32_t)]; // Buffer for event and CRC
    uint32_t crc;

    memset(buffer, 0, sizeof(SmartLockEvent) + sizeof(uint32_t));

    // Serialize the event
    memcpy(buffer, &event, sizeof(SmartLockEvent));

    // Calculate CRC for the serialized event
    crc = calculateCRC32(buffer, sizeof(SmartLockEvent));

    // Append CRC to the buffer
    memcpy(buffer + sizeof(SmartLockEvent), &crc, sizeof(crc));


    // Print the SmartLockEvent for debugging
    printf("SmartLockEvent:\n");
    printf("Timestamp: %u\n", event.timestamp);
    printf("EventType: %u\n", event.eventType);
    printf("UserId: %u\n", event.userId);
    printf("Method: %u\n", event.method);
    printf("Status: %u\n", event.status);

    // Print the serialized buffer (including CRC) for debugging
    printf("Serialized Buffer (including CRC):");
    for (size_t i = 0; i < sizeof(buffer); ++i) {
        if (i % 16 == 0) printf("\n"); // New line for readability every 16 bytes
        printf("%02X ", buffer[i]);
    }
    printf("\n");


    // Write the buffer to flash
    write_to_flash(sector, address, buffer, sizeof(buffer));


    // Read 256 byte data from Address=0
    memset(buf,0,256);
    n =  W25Q128_read(0, buf, 256);
    printf("Read Data: n=%d\n",n);
    dump(buf,256);

    return 1;
}
```

So our data is build like this:

```bash
00-03   Timestamp
04      Event-Type
05-06   User-Id
07      Method
08      Status
```

So, 9 bytes in total. But.. Not so fast, we cannot forget data alignment. The compiler will typically fill in padding bytes to make data access more efficient. So the *actual* layout is:

```bash
00-03   Timestamp
04      Event-Type
05      Padding1
06-07   User-Id
08      Method
09      Status
0A-0C   Padding2
```

So we have `12` bytes of log entry data plus `4` bytes for the checksum, in total one record is `16` bytes. Knowing this, we can now interpret the encrypted data fully.

```python
def process_data(data, key, /, modify, dump):
    # data records are 16 bytes each
    # 12 bytes 'SmartLockEvent' struct data
    #  4 bytes crc32
    for i in range(0, len(data), 16):
        record = bytearray([data[x] for x in range(i,i+12)])

        # decrypt record data (crc is not encrypted)
        for j in range(0, 12):
            record[j] = record[j] ^ key[j%len(key)]

        timestamp = struct.unpack_from("<I", record, offset=0)[0]
        event_id = record[4]
        user_id = struct.unpack_from("<H", record, offset=6)[0]
        method = record[8]
        success = record[9]
        crc = struct.unpack_from("<I", data, offset=i+12)[0]

        # unpack data for debug print
        if dump == True:
            print(f"[{i:04d}]: {timestamp}, {event_id:03d}, {user_id:04X}, {method}, {success}, {crc:08X}")

        # ...

if __name__ == "__main__":
    key = read_encryption_key()

    records = read_data(RECORDS_SIZE, 0)

    process_data(records, key, modify = False, dump = True)
```

This gives us the fully decoded log entry and, we can see, the last 4 log items are for our user (user-id: 0x5244). 
```bash
$ python client.py
[0000]: 1706207934, 005, 023F, 1, 1, 175DD498
[0016]: 1706262045, 249, 036F, 2, 1, C3EECDDB
[0032]: 1706322958, 108, 001C, 3, 1, B9E44CEB
[0048]: 1706325696, 005, 03B8, 2, 1, FE1D2E77
[0064]: 1706353558, 108, 001C, 2, 1, 8F921E35
[0080]: 1706354915, 092, 0115, 3, 1, 374423F5
[0096]: 1706366156, 249, 032B, 3, 1, 97E725BC
[0112]: 1706405776, 202, 032B, 2, 1, 61C2F80D
[0128]: 1706452080, 202, 0383, 2, 1, B5A77851
[0144]: 1706468159, 011, 023F, 3, 1, 211AB351
[0160]: 1706509360, 011, 0383, 1, 1, 4823C30F
[0176]: 1706609565, 187, 023F, 3, 1, 97FF08BF
[0192]: 1706680365, 108, 03B0, 1, 1, DD390AC5
[0208]: 1706755056, 005, 0383, 1, 1, E842E5CF
...
[2480]: 1712644769, 215, 023F, 2, 1, CE1CC663
[2496]: 1712702755, 214, 5244, 1, 1, 856C5BCF
[2512]: 1712714687, 187, 5244, 3, 1, CD8168EC
[2528]: 1712723427, 187, 5244, 3, 1, D047AD86
[2544]: 1712750575, 214, 5244, 3, 1, 2CD89BD1
```

So we have to change this to another user. Since we have the data in memory anyways we can just do so (and also update the checksum, while we are at it).

```python
def process_data(data, key, /, modify, dump):
  ...
  # modify the user with id 0x5244 to target another user
  if modify == True and user_id == 0x5244:
      struct.pack_into("<H", record, 6, 944)
      crc = binascii.crc32(record)
      for j in range(len(record)):
          data[i+j] = record[j] ^ key[j%len(key)]
      struct.pack_into("<I", data, i+12, crc)

if __name__ == "__main__":
    key = read_encryption_key()

    records = read_data(RECORDS_SIZE, 0)

    process_data(records, key, modify = False, dump = True)

    # process data and modify user records
    process_data(records, key, modify = True, dump = False)

    if DEBUG == True:
        # just dump the processed data to check everything is fine
        process_data(records, key, modify = False, dump = True)
```

So, what we are doing up to this point. We read the encryption key from `security register 1`, we read, decrypt and decode the log data. Then we update the user-id of the log entries which are associated to user `0x5244`, update the crc and encrypt the data again. 

The next step will be to write back the updated data. So we go back to our [`documentation`](https://docs.rs-online.com/9bfc/0900766b81704060.pdf) and see how we can do that.

> **Page Program (02h)**
> The Page Program instruction allows from one byte to 256 bytes (a page) of data to be programmed at
> previously erased (FFh) memory locations. A Write Enable instruction must be executed before the device
> will accept the Page Program Instruction (Status Register bit WEL= 1). The instruction is initiated by
> driving the /CS pin low then shifting the instruction code “02h” followed by a 24-bit address (A23-A0) and
> at least one data byte, into the DI pin. The /CS pin must be held low for the entire length of the instruction
> while data is being sent to the device. The Page Program instruction sequence is shown in Figure 29.
> If an entire 256 byte page is to be programmed, the last address byte (the 8 least significant address bits)
> should be set to 0. If the last address byte is not zero, and the number of clocks exceeds the remaining
> page length, the addressing will wrap to the beginning of the page. In some cases, less than 256 bytes (a
> partial page) can be programmed without having any effect on other bytes within the same page. One
> condition to perform a partial page program is that the number of clocks cannot exceed the remaining
> page length. If more than 256 bytes are sent to the device the addressing will wrap to the beginning of the
> page and overwrite previously sent data.

So there are two restrictions we need to keep in mind. We can only write to before `erased` memory and then we can write in `256 byte blocks` max. As it turns out the smallest unit of memory that can be erased is a sector (which is 4K-bytes).

> 8.2.17 Sector Erase (20h)
> The Sector Erase instruction sets all memory within a specified sector (4K-bytes) to the erased state of all
> 1s (FFh). A Write Enable instruction must be executed before the device will accept the Sector Erase
> Instruction (Status Register bit WEL must equal 1). The instruction is initiated by driving the /CS pin low
> and shifting the instruction code “20h” followed a 24-bit sector address (A23-A0). The Sector Erase
> instruction sequence is shown in Figure 31a & 31b.

So the plan is to erase the first sector, then split the log-records-set into 256 byte chunks and write them back, and then, hopefully, win the flag. To do write operations the `write enable bit` needs to be set *before every write operation*, so we add a few more operations to our client:

```python
def flash_wait_busy():
    while True:
        status = exchange([0x05], 1)[0]
        if status & 1 == 0:
            break

def flash_write_enable():
    res = exchange([0x06], 1)

def flash_sector_erase(addr):
    flash_write_enable()

    cmd = [0] * 4
    cmd[0] = 0x20
    cmd[1] = (addr >> 16) & 0xff
    cmd[2] = (addr >> 8)  & 0xff
    cmd[3] = (addr >> 0)  & 0xff

    exchange(cmd, 1)
    flash_wait_busy()

def write_data(data, addr):
    flash_write_enable()

    cmd = [0] * 4
    cmd[0] = 0x02
    cmd[1] = (addr >> 16) & 0xff
    cmd[2] = (addr >> 8)  & 0xff
    cmd[3] = (addr >> 0)  & 0xff

    for b in data:
        cmd.append(b)

    exchange(cmd, len(data))

    flash_wait_busy()

if __name__ == "__main__":
  ...

  # erase first sector (4k memory)
  flash_sector_erase(0)

  # write modified data back to sector. writes need to happen in
  # 256 block granularity
  block_size = 16*16
  for i in range(0, RECORDS_SIZE//block_size):
      offset = i*block_size
      write_data(records[offset:offset+block_size], offset)
```

Running this will update the full log with our tampered data. But where is the flag? If we scroll up in `client.py` we see one line `FLAG_ADDRESS = [0x52, 0x52, 0x52]`. Does this mean, the flag gets written to address `0x525252` when the log was updated successfully? Lets test this:

```python
if __name__ == "__main__":
  ...
  # read flag
  addr = (FLAG_ADDRESS[0] << 16) | (FLAG_ADDRESS[1] << 8) | FLAG_ADDRESS[2]
  flag = read_data(100, addr)
  print(flag.strip(b"\xff").decode())
```

```bash
$ python client.py
[0000]: 1706207934, 005, 023F, 1, 1, 175DD498
[0016]: 1706262045, 249, 036F, 2, 1, C3EECDDB
[0032]: 1706322958, 108, 001C, 3, 1, B9E44CEB
[0048]: 1706325696, 005, 03B8, 2, 1, FE1D2E77
...
HTB{n07h1n9_15_53cu23_w17h_phy51c41_4cc355!@}
```

The full source of [`client.py can be found here`](client.py).

Flag `HTB{n07h1n9_15_53cu23_w17h_phy51c41_4cc355!@}`