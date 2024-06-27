from data import memory, output
from struct import unpack_from

OFFSET_VALUE = 0xd

ops = []

for i in range(0, len(memory), 16):
    type_ = unpack_from("<I", memory, offset=i+0)[0]
    target_index = i//16
    index_lhs = unpack_from("<I", memory, offset=i+4)[0]

    if 1 <= type_ <= 3:
        index_rhs = unpack_from("<I", memory, offset=i+8)[0]
        ops.append((type_, target_index*16+OFFSET_VALUE, index_lhs, index_rhs))
    elif type_ == 4:
        ops.append((type_, (i-0xe00)//16, index_lhs, -1))

mem = bytearray(memory)
for type_, dst, idx1, idx2 in ops[::-1]:
    idx1 = idx1 * 16 + OFFSET_VALUE
    idx2 = idx2 * 16 + OFFSET_VALUE
    if type_ == 4:
        mem[idx1] = output[dst]
    if type_ == 1 or type_ == 2:
        mem[idx1] = (mem[dst] - mem[idx2])&0xff
        mem[idx2] = (mem[dst] + mem[idx1])&0xff
    if type_ == 3:
        mem[idx1] = mem[dst] ^ mem[idx2]
        mem[idx2] = mem[dst] ^ mem[idx1]

for i in range(OFFSET_VALUE, 32*16, 16):
    print(chr(mem[i]),end="")