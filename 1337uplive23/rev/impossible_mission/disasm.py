import sys
import struct

opcodes = {
    0x08 : ("PHP", 1),
    0x09 : ("ORA {0:x}", 2),
    0x0a : ("ASL", 1),
    0x0d : ("ORA {0:x}", 3),
    0x10 : ("BPL {0:x}", 2),
    0x18 : ("CLC", 1),
    0x20 : ("JSR {0:x}", 3),
    0x28 : ("PLP", 1),
    0x2a : ("ROL", 1),
    0x2d : ("AND {0:x}", 3),
    0x30 : ("BMI {0:x}", 2),
    0x38 : ("SEC", 1),
    0x48 : ("PHA", 1),
    0x49 : ("EOR {0:x}", 2),
    0x4c : ("JMP {0:x}", 3),
    0x4d : ("EOR {0:x}", 3),
    0x4e : ("LSR {0:x}", 3),
    0x55 : ("EOR {0:x}, x", 3),
    0x58 : ("CLI", 1),
    0x5d : ("EOR {0:x}, x", 3),
    0x60 : ("RTS", 1),
    0x68 : ("PLA", 1),
    0x69 : ("ADC {0:x}", 2),
    0x6a : ("ROR A", 1),
    0x6d : ("ADC {0:x}", 3),
    0x6e : ("ROR {0:x}", 3),
    0x78 : ("SEI", 1),
    0x84 : ("STY {0:x}", 2),
    0x85 : ("STA {0:x}", 2),
    0x88 : ("DEY", 1),
    0x8a : ("TXA", 1),
    0x8d : ("STA {0:x}", 3),
    0x86 : ("STX {0:x}", 2),
    0x8c : ("STX {0:x}", 3),
    0x8e : ("STX {0:x}", 3),
    0x90 : ("BCC {0:x}", 2),
    0x91 : ("STA ({0:x}), y", 2),
    0x98 : ("TYA", 1),
    0x99 : ("STA {0:x}, y", 3),
    0x9a : ("TXS", 1),
    0x9d : ("STA {0:x}, x", 3),
    0xa0 : ("LDY {0:x}", 2),
    0xa2 : ("LDX {0:x}", 2),
    0xa5 : ("LDA {0:x}", 2),
    0xa8 : ("TAY", 1),
    0xa9 : ("LDA {0:x}", 2),
    0xaa : ("TAX", 1),
    0xac : ("LDY {0:x}", 3),
    0xad : ("LDA {0:x}", 3),
    0xae : ("LDX {0:x}", 3),
    0xb1 : ("LDA ({0:x}), y", 2),
    0xb5 : ("LDA {0:x}, x", 2),
    0xb8 : ("CLV", 1),
    0xba : ("TSX", 1),
    0xbd : ("LDA {0:x}, x", 3),
    0xc3 : ("BCC {0:x}", 2),
    0xc6 : ("DEC {0:x}", 2),
    0xc8 : ("INY", 1),
    0xc9 : ("CMP {0:x}", 2),
    0xca : ("DEX", 1),
    0xcd : ("CMP {0:x}", 3),
    0xce : ("DEC {0:x}", 3),
    0xd0 : ("BNE {0:x}", 2),
    0xd8 : ("CLD", 1),
    0xe6 : ("INC {0:x}", 2),
    0xe8 : ("INX", 1),
    0xe9 : ("SBC {0:x}", 2),
    0xee : ("INC {0:x}", 3),
    0xf0 : ("BEQ {0:x}", 2),
    0xf8 : ("SED", 1),
    0xfe : ("INT {0:x}", 2),
}

if len(sys.argv) < 2: 
    print("missing filename")
    exit()

data = open(sys.argv[1], "rb").read()
#idx = struct.unpack("B", data[1:2])[0]
idx = int(sys.argv[2])
while idx < len(data):
    op = data[idx]

    if not op in opcodes:
        if op != 0:
            print(f"unknown opcode {op:02x}")
            break
        else:
            print(f"{idx:04x} some var")
            idx += 1
            continue

    name, size = opcodes[op]
    print(f"{idx:04x}", end=" ")
    if size == 1:
        print(name)
    elif size == 2:
        print(name.format(data[idx+1]))
    elif size == 3:
        print(name.format(struct.unpack("H", data[idx+1:idx+3])[0]))
    idx += size

