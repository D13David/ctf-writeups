# Hack The Boo 2022

## Secure Transfer

> Ghosts have been sending messages to each other through the aether, but we can't understand a word of it! Can you understand their riddles?
>
>  Author: N/A
>
> [`rev_securedtransfer.zip`](rev_securedtransfer.zip)

Tags: _rev_

## Preparation

This challenge is presented with two files. One pcap with just a few TCP packages and one program named ```securetransfer```. From the description can be seen that the captured traffic most likely contains some encrypted message. So first thing is to understand how the transfer works.

Opening the program in Ghidra it can be seen that symbols are stripped. So the best start is the ```entry``` function which calls ```__libc_start_main``` and the first function pointer of the first parameter points to the ```main``` function.

```c++
undefined8 main(int param_1,long param_2)
{
  OPENSSL_init_crypto(2,0);
  OPENSSL_init_crypto(0xc,0);
  OPENSSL_init_crypto(0x80,0);
  if (param_1 == 3) {
    printf("Sending File: %s to %s\n",*(undefined8 *)(param_2 + 0x10),*(undefined8 *)(param_2 + 8));
    sendFile(*(undefined8 *)(param_2 + 8),*(undefined8 *)(param_2 + 0x10));
  }
  else if (param_1 == 1) {
    puts("Receiving File");
    receiveFile();
  }
  else {
    puts("Usage ./securetransfer [<ip> <file>]");
  }
  return 0;
}
```

Main is very easy, the console output quickly reveals the functions which are called, so they can be renamed to ```sendFile``` and ```receiveFile```. Moving onwards to ```receiveFile```as the decryption part is from interest here. There is some connection setup code but also the actual receiver part.

```C++
sVar3 = read(socketRecv,&dataSize,8);
if (sVar3 == 8) {
    if (dataSize < 0x10) {
        puts("ERROR: File too small");
        close(local_60);
        uVar2 = 0;
    }
    else if (dataSize < 0x1001) {
        buffer = malloc(dataSize);
        sizeRead = read(socketRecv,buffer,dataSize);
        if (sizeRead == dataSize) {
            close(local_60);
            bufferTarget = malloc(dataSize + 1);
            iVar1 = decryptBuffer(buffer,dataSize & 0xffffffff,bufferTarget);
            local_40 = (long)iVar1;
            *(undefined *)(local_40 + (long)bufferTarget) = 0;
            printf("File Received...\n%s\n",bufferTarget);
            free(bufferTarget);
            free(buffer);
            uVar2 = 1;
        }
        else {
            puts("ERROR: File send doesn\'t match length");
            free(buffer);
            close(local_60);
            uVar2 = 0;
        }
    }
    else {
        puts("ERROR: File too large");
        close(local_60);
        uVar2 = 0;
    }
}
else {
    puts("ERROR: Reading secret length");
    close(local_60);
    uVar2 = 0;
}
```

The code first reads 8 bytes worth of information which are used to describe the buffer length of the message send afterwards. This can be noted to understand the communication protocol better. Afterwards a buffer is allocated and read through the socket. Whenever the read operation was successful another buffer is allocated and both are passed to a function which most likely handles decryption, thus is renamed to ```decryptBuffer```.

```C++
  local_38 = 's';
  local_2f = 'e';
  local_37 = 'u';
  local_36 = 'p';
  // ...
  local_1a = 'n';
  local_2c = 'e';
  local_35 = 'e';
  local_22 = 'n';
  iv = "someinitialvalue";
  local_40 = EVP_CIPHER_CTX_new();
  if (local_40 == (EVP_CIPHER_CTX *)0x0) {
    iVar1 = 0;
  }
  else {
    cipher = EVP_aes_256_cbc();
    iVar1 = EVP_DecryptInit_ex(local_40,cipher,(ENGINE *)0x0,&local_38,(uchar *)iv);
    if (iVar1 == 1) {
      iVar1 = EVP_DecryptUpdate(local_40,param_3,&local_50,param_1,param_2);
      if (iVar1 == 1) {
        local_4c = local_50;
        iVar1 = EVP_DecryptFinal_ex(local_40,param_3 + local_50,&local_50);
        if (iVar1 == 1) {
          local_4c = local_4c + local_50;
          EVP_CIPHER_CTX_free(local_40);
          iVar1 = local_4c;
        }
        else {
          iVar1 = 0;
        }
      }
      else {
        iVar1 = 0;
      }
    }
    else {
      iVar1 = 0;
    }
  }
```

This contains all the information we need. The encryption is done via *AES256 in CBC* mode. The *key* and *initialization vector* are given so we can write a small script for decryption. To retrieve the key the values need to be sorted since the order in the decompiled code is messed up.

```python
from Crypto.Cipher import AES

iv = b"someinitialvalue"
key = b"supersecretkeyusedforencryption!"

msg = b"..."

cipher = AES.new(key, AES.MODE_CBC, iv)
print(cipher.decrypt(msg))
```

Now the message is missing. The data can be retrieved out of the pcap capture. The first few packets are the TCP handshake. Afterwards 8 bytes of data are send, which is the buffer size.

```
0000   4e 63 2d e9 a8 57 b6 4a 26 4c 52 99 08 00 45 00   Nc-..W.J&LR...E.
0010   00 3c 16 eb 40 00 40 06 cf b2 0a 0d 20 02 0a 0d   .<..@.@..... ...
0020   20 03 98 1e 05 39 6f 08 45 41 e4 ba 44 fe 80 18    ....9o.EA..D...
0030   01 f6 54 4d 00 00 01 01 08 0a 4f 6e ac b2 e0 78   ..TM......On...x
0040   ad ed 20 00 00 00 00 00 00 00                     .. .......
```

And finally the actual message

```
0000   4e 63 2d e9 a8 57 b6 4a 26 4c 52 99 08 00 45 00   Nc-..W.J&LR...E.
0010   00 54 16 ec 40 00 40 06 cf 99 0a 0d 20 02 0a 0d   .T..@.@..... ...
0020   20 03 98 1e 05 39 6f 08 45 49 e4 ba 44 fe 80 19    ....9o.EI..D...
0030   01 f6 54 65 00 00 01 01 08 0a 4f 6e ac b2 e0 78   ..Te......On...x
0040   ad ed 5f 55 88 67 99 3d cc c9 98 79 f7 ca 39 c5   .._U.g.=...y..9.
0050   e4 06 97 2f 84 a3 a9 dd 5d 48 97 24 21 ff 37 5c   .../....]H.$!.7\
0060   b1 8c                                             ..
```

Extracting the data and putting it into the script 

```python
msg = b"\x5f\x55\x88\x67\x99\x3d\xcc\xc9\x98\x79\xf7\xca\x39\xc5\xe4\x06\x97\x2f\x84\xa3\xa9\xdd\x5d\x48\x97\x24\x21\xff\x37\x5c\xb1\x8c"
```

finally reveals the key ```HTB{vryS3CuR3_F1L3_TR4nsf3r}```