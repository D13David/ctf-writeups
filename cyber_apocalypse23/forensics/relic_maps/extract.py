import base64
from Crypto.Cipher import AES
import gzip

with open("payload") as file:
    lines = file.readlines()

key = base64.b64decode("0xdfc6tTBkD+M0zxU7egGVErAsa/NtkVIHXeHDUiW20=")
iv = base64.b64decode("2hn/J717js1MwdbbqMn7Lw==")
payload = base64.b64decode(lines[0])

cipher = AES.new(key, AES.MODE_CBC, iv)
decrypted = cipher.decrypt(payload)
decompressed = gzip.decompress(payload)

with open("payload.decrypted", "wb") as out:
    out.write(decompressed)
