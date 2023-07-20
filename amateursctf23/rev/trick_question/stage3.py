# Source Generated with Decompyle++
# File: dump.b (Python 3.10)

if input[:12] != 'amateursCTF{':
    return id.__self__.__dict__['False']
if None[-1] != '}':
    return id.__self__.__dict__['False']
input = None[12:-1]
if id.__self__.__dict__['len'](input) != 42:
    return id.__self__.__dict__['False']
underscores = None
for i, x in id.__self__.__dict__['enumerate'](input):
    if x == '_':
        underscores.append(i)
if underscores != [
    7,
    11,
    13,
    20,
    23,
    35]:
    return id.__self__.__dict__['False']
input = None.encode().split(b'_')
if input[0][::-1] != b'sn0h7YP':
    return id.__self__.__dict__['False']
if (None[1][0] + input[1][1] - input[1][2], input[1][1] + input[1][2] - input[1][0], input[1][2] + input[1][0] - input[1][1]) != (160, 68, 34):
    return id.__self__.__dict__['False']
if None.__self__.__dict__['__import__']('hashlib').sha256(input[2]).hexdigest() != '4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a':
    return id.__self__.__dict__['False']
r = None.__self__.__dict__['__import__']('random')
r.seed(input[2])
input[3] = id.__self__.__dict__['list'](input[3])
r.shuffle(input[3])
if input[3] != [
    49,
    89,
    102,
    109,
    108,
    52]:
    return id.__self__.__dict__['False']
if None[4] + b'freebie' != b'0ffreebie':
    return id.__self__.__dict__['False']
if None.__self__.__dict__['int'].from_bytes(input[5][0:4], 'little') ^ r.randint(0, 0xFFFFFFFFL) != 0xFBFF4501L:
    return id.__self__.__dict__['False']
if None.__self__.__dict__['int'].from_bytes(input[5][4:8], 'little') ^ r.randint(0, 0xFFFFFFFFL) != 825199122:
    return id.__self__.__dict__['False']
if None.__self__.__dict__['int'].from_bytes(input[5][8:12] + b'\x00', 'little') ^ r.randint(0, 0xFFFFFFFFL) != 0xFEEF2AA6L:
    return id.__self__.__dict__['False']
c = None
for i in input[6]:
    c *= 128
    c += i
if id.__self__.__dict__['hex'](c) != '0x29ee69af2f3':
    return id.__self__.__dict__['False']
return None.__self__.__dict__['True']
