# UMass CTF 2024

## Magic Conch

> Come one, come all! For a limited time only, The Magic Conch is answering your most pressing queries! Fun and knowledge will collide as you learn the deepest secrets of the unvierse! If your queries are thought-provoking enough, The Magic Conch may even present you with the flag! (Please keep your queries to 32 bytes or less; The Magic Conch does not have the patience for yappers)
> 
> [`magic_conch`](magic_conch)

Tags: _rev_

## Solution
The challenge comes with a binary we need to reverse. So lets inspect the file with `Ghidra`. Most of the symbols are stripped, so we don't find the main, but we can walk the flow by starting at `entry` instead and find that `FUN_0010152c` is the main function. The function is quite simple, it creates a [`anonymous file`](https://man7.org/linux/man-pages/man2/memfd_create.2.html). Then some content is written to the file and the file is opened as [`dynamic library`](https://linux.die.net/man/3/dlopen), the symbol `EntryPoint` is looked up and then the function `EntryPoint` is executed.

The payload itself is stored as data within the original binary (`DAT_00102020`), but is passed through two functions before. Lets see what is happening there.

```c
undefined8 main(void)
{
  char local_78 [64];
  uint local_38;
  undefined4 local_34;
  code *local_30;
  long local_28;
  uint local_1c;
  void *local_18;
  void *local_10;
  
  local_10 = (void *)FUN_00101418(&DAT_00102020,&local_34);
  if (local_10 == (void *)0x0) {
                    /* WARNING: Subroutine does not return */
    exit(1);
  }
  local_18 = (void *)FUN_00101284(local_10,local_34,&local_38);
  if (local_18 == (void *)0x0) {
                    /* WARNING: Subroutine does not return */
    exit(1);
  }
  free(local_10);
  local_1c = memfd_create("payload_file",0);
  if (local_1c == 0) {
                    /* WARNING: Subroutine does not return */
    exit(1);
  }
  write(local_1c,local_18,(ulong)local_38);
  sprintf(local_78,"/proc/self/fd/%d",(ulong)local_1c);
  local_28 = dlopen(local_78,1);
  if (local_28 == 0) {
    free(local_10);
                    /* WARNING: Subroutine does not return */
    exit(1);
  }
  local_30 = (code *)dlsym(local_28,"EntryPoint");
  if (local_30 == (code *)0x0) {
    free(local_10);
    dlclose(local_28);
                    /* WARNING: Subroutine does not return */
    exit(1);
  }
  (*local_30)();
  dlclose(local_28);
  close(local_1c);
  free(local_18);
  return 0;
}
```

First function `FUN_00101418`. After some cleanup it becomes clear the input buffer is a hex-string and converted to a byte array (just like `unhexlify` would do in Python context).

```c
uchar * FUN_00101418(char *buffer_in,int *length)
{
  int iVar1;
  int iVar2;
  size_t buffer_length;
  uchar *result;
  long offset;
  ulong i;
  
  buffer_length = strlen(buffer_in);
  if ((buffer_length & 1) == 0) {
    *length = (int)(buffer_length >> 1);
    result = (uchar *)malloc((ulong)(uint)*length);
    if (result == (uchar *)0x0) {
      result = (uchar *)0x0;
    }
    else {
      offset = 0;
      for (i = 0; i < buffer_length; i = i + 2) {
        iVar1 = Hex2Dec((int)buffer_in[i]);
        iVar2 = Hex2Dec((int)buffer_in[i + 1]);
        if ((iVar1 == -1) || (iVar2 == -1)) {
          free(result);
          return (uchar *)0x0;
        }
        result[offset] = (byte)(iVar1 << 4) | (byte)iVar2;
        offset = offset + 1;
      }
    }
  }
  else {
    result = (uchar *)0x0;
  }
  return result;
}
```

We can change the calling part for more readability:

```c
payload_byte_data = ConvertToByteArray(&DAT_00102020,&payload_length);
if (payload_byte_data == (uchar *)0x0) {
                  /* WARNING: Subroutine does not return */
  exit(1);
}
...
```

Next is function `FUN_00101284`. The function takes the byte array from before and does an `AES128 CBC` decryption on it. The `key` and `iv` are also stored in as data within the binary (`DAT_0010c090` and `DAT_0010c0b0`), but decoded before by passing it through function `FUN_00101229`.

```c
uchar * FUN_00101284(uchar *buffer,int input_length,int *output_length)
{
  int iVar1;
  uchar *out;
  EVP_CIPHER_CTX *ctx;
  EVP_CIPHER *pEVar2;
  
  out = (uchar *)malloc(100000);
  if (out == (uchar *)0x0) {
    free((void *)0x0);
    out = (uchar *)0x0;
  }
  else {
    ctx = EVP_CIPHER_CTX_new();
    if (ctx == (EVP_CIPHER_CTX *)0x0) {
      free(out);
      out = (uchar *)0x0;
    }
    else {
      FUN_00101229(&DAT_0010c090,"C++ IS GARBAGE!!",0x10);
      FUN_00101229(&DAT_0010c0b0,"C++ IS GARBAGE!!",0x10);
      pEVar2 = EVP_aes_128_cbc();
      iVar1 = EVP_DecryptInit_ex2(ctx,pEVar2,&DAT_0010c090,&DAT_0010c0b0,0);
      if (iVar1 == 0) {
        free(out);
        EVP_CIPHER_CTX_free(ctx);
        out = (uchar *)0x0;
      }
      else {
        iVar1 = EVP_DecryptUpdate(ctx,out,output_length,buffer,input_length);
        if (iVar1 == 0) {
          free(out);
          EVP_CIPHER_CTX_free(ctx);
          out = (uchar *)0x0;
        }
        else {
          EVP_CIPHER_CTX_free(ctx);
        }
      }
    }
  }
  return out;
}
```

Lets quickly have a look what `FUN_00101229` actually does. It implements a simple xor functionality of a given buffer with a given key. The xor key in this case is hardcoded to be `"C++ IS GARBAGE!!"`, so we can easily reconstruct the correct `AES key` and `iv`.

```c
void FUN_00101229(uchar *buffer,uchar *key,int length)
{
  int i;
  
  for (i = 0; i < length; i = i + 1) {
    buffer[i] = buffer[i] ^ key[i];
  }
  return;
}
```

Thats basically all we need to retrieve the payload for futher analysis. We grab all the encrypted data from the data section and write a small script that decryptes the payload binary for us.

```python
from Crypto.Cipher import AES
from binascii import unhexlify

payload = "b9646c6897181668d267c4b1cc02ccb3b..."
key = bytearray(b'\x1a\x6e\x67\x6c\x06\x04\x00\x14\x14\x10\x0f\x00\x15\x0c\x6f\x64')
iv = bytearray(b'\x69\x68\x63\x69\x0a\x18\x65\x09\x61\x1c\x17\x06\x00\x00\x75\x0b')
xor_key = b"C++ IS GARBAGE!!"

for i in range(16):
    key[i] ^= xor_key[i]
    iv[i] ^= xor_key[i]

print(f"found key: {key.decode()}")
print(f"found iv: {iv.decode()}")

cipher = AES.new(key, AES.MODE_CBC, iv)
try:
    payload = cipher.decrypt(unhexlify(payload))
except ValueError as ex:
    print("Decryption failed:", ex)
    exit()

open("payload", "wb").write(payload)
```

After running the script we can find the decrypted binary written to `payload`.

```bash
$ file payload
payload: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, BuildID[sha1]=91513e0e4b21b11d517a7cd304495863a3fb6198, not stripped
```

The file contains debugging symbols, that makes things easier. So let's check out `EntryPoint`. The function basically checks for two `environment variables`, one is `FLAG` the other is `PORT`. If both are present the function creates a listening socket. Accepted connections are handled within `thread_start`. 

```c
void EntryPoint(void)
{
  int iVar1;
  pthread_t local_50;
  sockaddr local_48;
  int local_30;
  socklen_t local_2c;
  sockaddr local_28;
  int local_14;
  char *local_10;
  
  FLAG = getenv("FLAG");
  if (FLAG == (char *)0x0) {
    puts("ERROR: Environment variable FLAG not set");
                    /* WARNING: Subroutine does not return */
    exit(1);
  }
  local_10 = getenv("PORT");
  if (local_10 == (char *)0x0) {
    puts("ERROR: Environment variable PORT not set");
                    /* WARNING: Subroutine does not return */
    exit(1);
  }
  PORT = atoi(local_10);
  local_2c = 0x10;
  local_14 = socket(2,1,0);
  if (local_14 < 0) {
                    /* WARNING: Subroutine does not return */
    exit(1);
  }
  local_28.sa_family = 2;
  local_28.sa_data[2] = '\0';
  local_28.sa_data[3] = '\0';
  local_28.sa_data[4] = '\0';
  local_28.sa_data[5] = '\0';
  local_28.sa_data._0_2_ = htons((uint16_t)PORT);
  iVar1 = bind(local_14,&local_28,0x10);
  if (iVar1 < 0) {
                    /* WARNING: Subroutine does not return */
    exit(1);
  }
  iVar1 = listen(local_14,10);
  if (iVar1 < 0) {
                    /* WARNING: Subroutine does not return */
    exit(1);
  }
  printf("Listening on port %d...\n",(ulong)PORT);
  while( true ) {
    local_30 = accept(local_14,&local_48,&local_2c);
    if (local_30 < 0) break;
    pthread_create(&local_50,(pthread_attr_t *)0x0,thread_start,&local_30);
  }
                    /* WARNING: Subroutine does not return */
  exit(1);
}
```

The function `thread_start` is somewhat lengthy. Let's break this down a bit. After some initialization the server sends a welcome message and reads a value back from the client. The data is passed to `HASH` function and checked if the result is `NULL`. If the result is `NULL` an error is send back.

```c
  memset(local_48,0,0x21);
  memset(local_78,0,0x21);
  memset(local_c8,0,0x41);
  memset(local_118,0,0x41);
  memset(local_218,0,0x100);
  memset(local_318,0,0x100);
  local_c = *param_1;
  sVar2 = strlen(welcome);
  send(local_c,welcome,sVar2,0);
  send(local_c,"Query 1: ",9,0);
  recv(local_c,local_48,0x21,0);
  local_18 = (void *)HASH(local_48);
  if (local_18 == (void *)0x0) {
    sVar2 = strlen(errmsg);
    send(local_c,errmsg,sVar2,0);
  }
```

Function `HASH` creates a `SHA256` hash for a given buffer, but before does an `xor` operation on the input. Interestingly both the data as well as the xor key are provided by the user as input. The decompiler struggles a bit with recreating structs, but we can fix this manually.

```c
uchar * HASH(undefined8 *param_1)
{
  uchar local_58 [32];
  undefined8 local_38;
  undefined8 local_30;
  undefined8 local_28;
  undefined8 local_20;
  uchar *local_10;
  
  memset(&local_28,0,0x10);
  memset(&local_38,0,0x10);
  memset(local_58,0,0x20);
  local_20 = param_1[1];
  local_28 = *param_1;
  local_30 = param_1[3];
  local_38 = param_1[2];
  Xor(&local_28,&local_38,local_58,0x10);
  local_10 = (uchar *)malloc(0x20);
  SHA256(local_58,0x20,local_10);
  return local_10;
}
```

We define a `struct user_input_s`, that makes things a bit more readable...

```c
uchar * HASH(user_input_s *input)

{
  uchar *md;
  uchar buffer [32];
  char key [16];
  char data [16];
  
  memset(data,0,16);
  memset(key,0,16);
  memset(buffer,0,32);
  data._8_8_ = *(undefined8 *)(input->data + 8);
  data._0_8_ = *(undefined8 *)input->data;
  key._8_8_ = *(undefined8 *)(input->key + 8);
  key._0_8_ = *(undefined8 *)input->key;
  Xor(data,key,buffer,0x10);
  md = (uchar *)malloc(32);
  SHA256(buffer,0x20,md);
  return md;
}
```

Let's check out the full `thread_start` function. The server reads two user inputs. Each user input contains 2*16 bytes. The two arrays are xored and then the `SHA256` hash value is computed on the xor result. This happens for **both** the user inputs.

```c
void thread_start(int *param_1)

{
  int cmp;
  size_t sVar1;
  char buffer1 [256];
  char buffer2 [256];
  char buffer3 [256];
  undefined hash_query2_hexstr [80];
  undefined hash_query1_hexstr [80];
  user_input_s user_input_query2;
  user_input_s user_input_query1;
  void *hash_query2;
  void *hash_query1;
  int local_c;
  
  memset(&user_input_query1,0,33);
  memset(&user_input_query2,0,33);
  memset(hash_query1_hexstr,0,0x41);
  memset(hash_query2_hexstr,0,0x41);
  memset(buffer3,0,0x100);
  memset(buffer2,0,0x100);
  local_c = *param_1;
  sVar1 = strlen(welcome);
  send(local_c,welcome,sVar1,0);
  send(local_c,"Query 1: ",9,0);
  recv(local_c,&user_input_query1,0x21,0);
  hash_query1 = (void *)HASH(&user_input_query1);
  if (hash_query1 == (void *)0x0) {
    sVar1 = strlen(errmsg);
    send(local_c,errmsg,sVar1,0);
  }
  else {
    bytes_to_hex(hash_query1,hash_query1_hexstr);
    sprintf(buffer3,"Magic Conch says: %s\n",hash_query1_hexstr);
    sVar1 = strlen(buffer3);
    send(local_c,buffer3,sVar1,0);
    send(local_c,"Query 2: ",9,0);
    recv(local_c,&user_input_query2,0x21,0);
    hash_query2 = (void *)HASH(&user_input_query2);
    if (hash_query2 == (void *)0x0) {
      sVar1 = strlen(errmsg);
      send(local_c,errmsg,sVar1,0);
      free(hash_query1);
    }
    else {
      bytes_to_hex(hash_query2,hash_query2_hexstr);
      sprintf(buffer2,"Magic Conch says: %s\n",hash_query2_hexstr);
      sVar1 = strlen(buffer2);
      send(local_c,buffer2,sVar1,0);
      cmp = memcmp(&user_input_query1,&user_input_query2,32);
      if (cmp == 0) {
        sVar1 = strlen(repeat);
        send(local_c,repeat,sVar1,0);
      }
      else {
        cmp = memcmp(hash_query1,hash_query2,32);
        if (cmp == 0) {
          buffer1[0] = '\0';
          buffer1[1] = '\0';
          ...
          buffer1[254] = '\0';
          buffer1[255] = '\0';
          sprintf(buffer1,"The Magic Conch is pleased with your queries. Here is your reward: %s\n",
                  FLAG);
          sVar1 = strlen(buffer1);
          send(local_c,buffer1,sVar1,0);
        }
        else {
          sVar1 = strlen(fail);
          send(local_c,fail,sVar1,0);
        }
      }
      free(hash_query1);
      free(hash_query2);
    }
  }
  close(local_c);
                    /* WARNING: Subroutine does not return */
  pthread_exit((void *)0x0);
}
```

A bit further down the road the code checks two conditions. First it checks if the user inputs are `different`. If not the program ends with an error. And then it checks if the hash values of both user inputs are the `same`. If both conditions are met, the flag is displayed. To get the flag we need to find two different inputs that produce the same hash. First thought might be to check for hash collisions, but remember the xor running over the input? We can easily produce the same input for hashing by swapping `data` and `key`. For instance sending `aaaaaaaaaaaaaaaabbbbbbbbbbbbbbbb` and `bbbbbbbbbbbbbbbbaaaaaaaaaaaaaaaa` produces the same result after xor resulting in the same hash value while being completely different inputs.

Lets try this:

```bash
$ nc magic-conch.ctf.umasscybersec.org 1337
Welcome! You may ask the Magic Conch ~two~ queries
Query 1: aaaaaaaaaaaaaaaabbbbbbbbbbbbbbbb
Magic Conch says: d32539b4035c8db5a0268ede49e31f0bb5e00558f50866659cfd46af5a0a5bf5
Query 2: bbbbbbbbbbbbbbbbaaaaaaaaaaaaaaaa
Magic Conch says: d32539b4035c8db5a0268ede49e31f0bb5e00558f50866659cfd46af5a0a5bf5
The Magic Conch is pleased with your queries. Here is your reward: UMASS{dYN4M1C_an4ly$1s_4_Th3_w1n}
```

Flag `UMASS{dYN4M1C_an4ly$1s_4_Th3_w1n}`