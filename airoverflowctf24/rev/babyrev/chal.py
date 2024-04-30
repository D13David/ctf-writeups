import codecs
import base64
import sys

def KSA(key):
    S = list(range(256)) # added list to make it compatible with python3
    j = 0
    for i in range(256):
        j = (j + S[i] + key[i % len(key)]) % 256
        S[i], S[j] = S[j], S[i]

    return S

def PRGA(S):
    i = 0
    j = 0
    while True:
        i = (i + 1) % 256
        j = (j + S[i]) % 256
        S[i], S[j] = S[j], S[i]

        K = S[(S[i] + S[j]) % 256]
        yield K

def encrypt(plaintext):
    key = 'Rivest'
    plaintext = [ord(p) for p in plaintext]
    key = [ord(k) for k in key]
    keystream = PRGA(KSA(key))
    enc = []

    for i in range(len(plaintext)):
        enc.append(plaintext[i] ^ next(keystream))

    byte_string = bytes(enc)
    b64_enc = base64.b64encode(byte_string)
    return b64_enc

flag = input('Please enter the flag: ')
enc_flag = encrypt(flag)
if enc_flag == b'aJlQBCwh9JM2RHmXLy+PA6cUIFDC3A==':
    print('Correct!')
else:
    print('Wrong!')