import hashlib

with open("./crypto_perfect_synchronization/output.txt", 'r') as f:
    lines = f.readlines()

alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
i = 0
d = {}

result = []
for line in lines:
    b = bytearray(line.encode())
    s = hashlib.md5(b).hexdigest()
    if i < len(alphabet):
        if not s in d:
            d[s] = alphabet[i]
            i = i + 1
        result.append(d[s])
    else:
        print("skip")

print("".join(str(x) for x in result))
